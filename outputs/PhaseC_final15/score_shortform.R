
score_shortform <- function(df_row, lookup_tbl) {
  # df_row: named vector/list with short-form item responses coded as in calibration
  # lookup_tbl: data.frame with raw_sum15 and theta_hat
  # Returns: list(theta_hat, raw_sum15)
  rs <- sum(unlist(df_row), na.rm = TRUE)
  # clamp
  rs_clamped <- max(min(rs, max(lookup_tbl$raw_sum15)), min(lookup_tbl$raw_sum15))
  th <- lookup_tbl$theta_hat[lookup_tbl$raw_sum15 == rs_clamped][1]
  list(theta_hat = as.numeric(th), raw_sum15 = rs)
}

