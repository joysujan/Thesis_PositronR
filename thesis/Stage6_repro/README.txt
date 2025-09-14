# Thesis reproducibility bundle

Contents:
- code/main_recreate_exhibits.R: minimal script to regenerate core figures from saved CSVs.
- outputs/: CSVs and RDS used in the manuscript (psychometrics, calibration, ROC).
- figs/: thesis figures and regenerated replicas.

Software:
- R (list versions used in thesis); packages: mirt, pROC, ggplot2, dplyr, readr.

Run:
1) Open code/main_recreate_exhibits.R and source it.
2) Figures will be written to figs/ with prefix rep_fig_.

Mapping (exhibits -> files):
- TIF overlay: outputs/PhaseC_final15/test_info_reduced_15.csv, outputs/PhaseC_drop_packet/test_info_base.csv.
- Calibration table: outputs/PhaseC_final/link_lm_summary.csv; plot from thesis/PhaseC_B_calibration/scores_with_theta_cal.csv.
- Operating points: thesis/PhaseC_C_roc/roc_operating_points.csv; annotated ROC in figs/.

Data availability:
- Person-level raw data are not included; this bundle uses derived CSVs from the thesis pipeline.
- For full re-estimation, see data/ pointers and Phase C scripts in the project.

Notes:
- PPV/NPV depend on observed prevalence; reported values in operating_points.csv reflect the study prevalence.
- Re-generated figures should match the manuscript within minor rendering differences (fonts, antialiasing).
