
get_item_order <- function(mod, params_csv_fallback = NULL){
  # Ensure mirt S4 methods are registered
  if (!"package:mirt" %in% search()) suppressPackageStartupMessages(library(mirt))
  items <- NULL; ok <- FALSE
  if (methods::is(mod, "SingleGroupClass")) {
    cf <- try(mirt::coef(mod, IRTpars = TRUE, simplify = TRUE), silent = TRUE)
    if (!inherits(cf, "try-error") && is.list(cf) && !is.null(cf$items)) {
      items <- rownames(cf$items); ok <- TRUE
    }
  }
  if (!ok && !is.null(params_csv_fallback) && file.exists(params_csv_fallback)) {
    pc <- readr::read_csv(params_csv_fallback, show_col_types = FALSE)
    if ("item" %in% names(pc)) { items <- pc$item; ok <- TRUE }
  }
  if (!ok) stop("Could not determine item order. Ensure mirt is loaded and mod15.rds is a mirt SingleGroupClass; or provide params_csv_fallback.")
  items
}

check_model <- function(mod){
  if (!methods::is(mod, "SingleGroupClass")) {
    stop("mod15.rds is not a mirt SingleGroupClass. Point assets_dir to the correct file.")
  }
  invisible(TRUE)
}

