
#' Score DASS-15 and optionally approximate DASS-21
#'
#' Compute IRT EAP theta and SE from the 15-item short form, calibrate to the SEM latent,
#' apply the published ROC cut for an elevated flag, and optionally return an approximate
#' DASS-21 total and category via pre-trained links (equipercentile or linear).
#'
#' @param df Data frame with the 15 DASS short-form item columns coded 0..3, names matching the model.
#' @param cut Character. Operating point name; one of 'Youden' or 'Sens>=0.80'. Default 'Youden'.
#' @param legacy Logical. If TRUE, return approximate DASS-21 total/category. Default TRUE.
#' @param legacy_method 'equiperc' (default) or 'linear' for legacy mapping.
#' @return A data.frame with columns: theta, se, theta_cal, elevated, and optional legacy fields.
#' @examples
#' ex <- readr::read_csv(system.file('examples','example_input_20rows.csv', package='dasssf15'), show_col_types = FALSE)
#' out <- score_shortform(ex, cut='Youden', legacy=TRUE, legacy_method='equiperc')
#' head(out)
#' @export
score_shortform <- function(df, cut = c('Youden','Sens>=0.80'),
                            legacy = TRUE, legacy_method = c('equiperc','linear')){
  cut <- match.arg(cut); legacy_method <- match.arg(legacy_method)
  if (!'package:mirt' %in% search()) suppressPackageStartupMessages(library(mirt))

  # Locate assets inside package
  ext <- system.file('extdata', package = 'dasssf15')
  mod  <- readRDS(file.path(ext, 'mod15.rds')); check_model(mod)
  link <- readRDS(file.path(ext, 'link_theta_to_sem.rds'))
  ops  <- readr::read_csv(file.path(ext, 'roc_operating_points.csv'), show_col_types = FALSE)

  # Item order and input coercion
  items_order <- get_item_order(mod, params_csv_fallback = file.path(ext, 'item_parameters_min.csv'))
  to_num <- function(x){
    if (is.factor(x)) as.numeric(as.character(x))
    else if (inherits(x, 'haven_labelled')) as.numeric(as.character(haven::as_factor(x)))
    else as.numeric(x)
  }
  if (!all(items_order %in% names(df))) {
    missing <- setdiff(items_order, names(df))
    stop(sprintf('Input missing %d item(s): %s', length(missing), paste(missing, collapse = ', ')))
  }
  X <- as.data.frame(lapply(df[, items_order, drop = FALSE], to_num))
  all_na <- apply(X, 1, function(z) all(is.na(z)))
  if (any(all_na)) warning(sum(all_na), ' rows have all items missing; theta will be NA there.')

  # EAP scoring
  sc <- mirt::fscores(mod, method = 'EAP', full.scores.SE = TRUE, response.pattern = X)
  theta <- as.numeric(sc[, 'F1']); se <- as.numeric(sc[, 'SE_F1'])

  # Calibration
  theta_cal <- as.numeric(stats::predict(link, newdata = data.frame(theta = theta)))

  # ROC threshold and elevated flag
  thr <- ops$threshold[match(cut, ops$cut_name)]; if (length(thr) != 1 || is.na(thr)) thr <- ops$threshold[21]
  elevated <- ifelse(theta >= thr, 1L, 0L)

  out <- data.frame(theta = theta, se = se, theta_cal = theta_cal, elevated = elevated)

  # Approximate DASS-21 display
  if (legacy) {
    dasst <- rep(NA_real_, length(theta))
    if (legacy_method == 'equiperc' && file.exists(file.path(ext, 'legacy_link_equiperc.csv'))) {
      eq <- readr::read_csv(file.path(ext, 'legacy_link_equiperc.csv'), show_col_types = FALSE)
      p <- approx(eq$q_theta, eq$p, xout = theta, rule = 2)$y
      dasst <- approx(eq$p, eq$q_dass21, xout = p, rule = 2)$y
    } else if (legacy_method == 'linear' && file.exists(file.path(ext, 'legacy_link_linear_coeffs.csv'))) {
      co <- readr::read_csv(file.path(ext, 'legacy_link_linear_coeffs.csv'), show_col_types = FALSE)
      b0 <- co$estimate[co$term == '(Intercept)']; b1 <- co$estimate[co$term == 'theta']
      dasst <- b0 + b1 * theta
    }
    dasst <- pmax(0, round(dasst))
    cuts <- c(0,10,14,21,28)
    labs <- c('Normal','Mild','Moderate','Severe','Extremely Severe')
    cat_idx <- cut(dasst, breaks = c(-Inf, cuts[-1]-1, Inf), labels = labs, right = TRUE, include.lowest = TRUE)
    out$dass21_total_approx <- as.integer(dasst)
    out$dass21_category_approx <- as.character(cat_idx)
  }

  out
}

