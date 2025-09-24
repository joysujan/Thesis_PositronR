
# Scoring for the 15-item DASS short form
score_shortform <- function(df, assets_dir = "kit/assets", tables_dir = "kit/tables",
                            cut = c("Youden","Sens>=0.80"), legacy = FALSE, legacy_method = c("linear","equiperc")){
  cut <- match.arg(cut); legacy_method <- match.arg(legacy_method)
  if (!"package:mirt" %in% search()) suppressPackageStartupMessages(library(mirt))
  source(file.path(dirname(tables_dir), "code", "helpers.R"))

  # Load assets
  mod  <- readRDS(file.path(assets_dir, "mod15.rds")); check_model(mod)
  link <- readRDS(file.path(assets_dir, "link_theta_to_sem.rds"))

  # Item order (fallback to CSV if needed)
  params_fallback <- file.path(tables_dir, "item_parameters_min.csv")
  items_order <- get_item_order(mod, params_csv_fallback = params_fallback)

  # Coerce input
  to_num <- function(x){
    if (is.factor(x)) as.numeric(as.character(x))
    else if (inherits(x, "haven_labelled")) as.numeric(as.character(haven::as_factor(x)))
    else as.numeric(x)
  }
  if (!all(items_order %in% names(df))) {
    missing <- setdiff(items_order, names(df))
    stop(sprintf("Input is missing %d required items: %s", length(missing), paste(missing, collapse = ", ")))
  }
  X <- as.data.frame(lapply(df[, items_order, drop = FALSE], to_num))
  all_na <- apply(X, 1, function(z) all(is.na(z)))
  if (any(all_na)) warning(sum(all_na), " rows have all 15 items missing; theta will be NA for those rows.")

  # EAP theta and SE
  fs <- mirt::fscores(mod, method = "EAP", full.scores.SE = TRUE, response.pattern = X)
  theta <- as.numeric(fs[, "F1"]); se <- as.numeric(fs[, "SE_F1"])

  # Calibration to SEM latent
  theta_cal <- as.numeric(predict(link, newdata = data.frame(theta = theta)))

  # Operating point
  ops <- readr::read_csv(file.path(tables_dir, "roc_operating_points.csv"), show_col_types = FALSE)
  thr <- ops$threshold[match(cut, ops$cut_name)]; if (length(thr) != 1 || is.na(thr)) thr <- ops$threshold[3]
  elevated <- ifelse(theta >= thr, 1L, 0L)

  out <- data.frame(theta = theta, se = se, theta_cal = theta_cal, elevated = elevated)

  # Optional legacy mapping
  if (legacy) {
    dasst <- rep(NA_integer_, length(theta))
    if (legacy_method == "linear" && file.exists(file.path(tables_dir, "legacy_link_linear_coeffs.csv"))){
      co <- readr::read_csv(file.path(tables_dir, "legacy_link_linear_coeffs.csv"), show_col_types = FALSE)
      b0 <- co$estimate[co$term == "(Intercept)"]; b1 <- co$estimate[co$term == "theta"]
      dasst <- pmax(0, round(b0 + b1 * theta))
    } else if (legacy_method == "equiperc" && file.exists(file.path(tables_dir, "legacy_link_equiperc.csv"))){
      eq <- readr::read_csv(file.path(tables_dir, "legacy_link_equiperc.csv"), show_col_types = FALSE)
      p <- approx(eq$q_theta, eq$p, xout = theta, rule = 2)$y
      dasst <- pmax(0, round(approx(eq$p, eq$q_dass21, xout = p, rule = 2)$y))
    } else {
      warning("Legacy mapping assets not found or method unsupported; skipping legacy outputs.")
    }
    cut_total <- c(0, 10, 14, 21, 28)
    labs_total <- c("Normal","Mild","Moderate","Severe","Extremely Severe")
    cat_idx <- cut(dasst, breaks = c(-Inf, cut_total[-1] - 1, Inf),
                   labels = labs_total, right = TRUE, include.lowest = TRUE)
    out$dass21_total_approx <- dasst
    out$dass21_category_approx <- as.character(cat_idx)
  }
  out
}

