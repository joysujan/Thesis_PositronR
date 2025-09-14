# DASS Short-Form (15 items) Scoring Kit

Use:
  source('kit/code/score_shortform.R')
  scores <- score_shortform(df, cut = 'Youden', legacy = TRUE)

Inputs:
  df: data.frame with 15 item columns (names must match model; codes 0..3).

Outputs:
  theta, se, theta_cal, elevated (ROC-based flag), optional dass21_total_approx and category.

Assets:
  assets/mod15.rds (mirt SingleGroupClass), assets/link_theta_to_sem.rds, tables/roc_operating_points.csv
  tables/legacy_* (optional), tables/item_parameters_min.csv (fallback for item names).

Notes:
  - Decisions should use theta/theta_cal and the ROC-based flag; legacy categories are for communication only.
  - Re-estimate ROC with pROC if external labels are available in a new dataset.

Smoke test:
  Rscript kit/code/run_example.R
