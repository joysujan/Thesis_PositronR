
# Recreate key thesis exhibits (minimal)
library(readr); library(dplyr); library(ggplot2); library(mirt); library(pROC)

# A) Load and plot TIF overlay from saved CSVs
red <- read_csv("outputs/PhaseC_final15/test_info_reduced_15.csv", show_col_types = FALSE) %>% mutate(model = "Reduced-15")
base <- read_csv("outputs/PhaseC_drop_packet/test_info_base.csv", show_col_types = FALSE) %>% mutate(model = "Baseline-21")
tif_df <- bind_rows(red, base)
band_lo <- 0.0; band_hi <- 2.0
p_tif <- ggplot(tif_df, aes(theta, test_info, color = model)) +
  annotate("rect", xmin = band_lo, xmax = band_hi, ymin = -Inf, ymax = Inf, fill = "#ecfeff", alpha = 0.5) +
  geom_line(size = 1.1) +
  labs(title = "Test information overlay", x = expression(theta), y = "Information") +
  theme(legend.position = "bottom")
ggsave("figs/rep_fig_tif_overlay.png", p_tif, width = 9, height = 6, dpi = 200)

# B) Calibration plot from scores_with_theta_cal
sc <- read_csv("thesis/PhaseC_B_calibration/scores_with_theta_cal.csv", show_col_types = FALSE)
p_cal <- ggplot(sc %>% filter(is.finite(theta), is.finite(theta_cal)), aes(theta, theta_cal)) +
  geom_point(alpha = 0.25, size = 1.2, color = "#0f766e") +
  geom_smooth(method = "lm", se = TRUE, color = "#0ea5e9") +
  labs(title = "Calibration: theta to SEM latent", x = "theta (EAP)", y = "theta_cal") +
  theme_minimal(11)
ggsave("figs/rep_fig_calibration.png", p_cal, width = 6.4, height = 4.5, dpi = 200)

# C) ROC (optional if analysis set available)
if (file.exists("thesis/PhaseC_C_roc/roc_analysis_set.csv")){
  df <- read_csv("thesis/PhaseC_C_roc/roc_analysis_set.csv", show_col_types = FALSE)
  roc_obj <- pROC::roc(response = df$high_distress, predictor = df$theta, quiet = TRUE, direction = ">")
  auc_ci  <- pROC::ci.auc(roc_obj)
  png("figs/rep_fig_ROC.png", width = 900, height = 650, res = 140)
  plot(roc_obj, print.auc = TRUE, col = "#059669",
       main = sprintf("ROC: AUC=%.3f; 95%% CI %.3f–%.3f", as.numeric(auc_ci[22]), as.numeric(auc_ci[21]), as.numeric(auc_ci[23])))
  abline(0,1,lty=2,col="grey60"); dev.off()
}

