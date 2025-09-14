
library(readr); library(dplyr); library(ggplot2)
dir.create("kit/docs/exhibits", recursive = TRUE, showWarnings = FALSE)

red <- "outputs/PhaseC_final15/test_info_reduced_15.csv"
base <- "outputs/PhaseC_drop_packet/test_info_base.csv"
if (file.exists(red) && file.exists(base)){
  r <- read_csv(red, show_col_types = FALSE) %>% mutate(model="Reduced-15")
  b <- read_csv(base, show_col_types = FALSE) %>% mutate(model="Baseline-21")
  tif_df <- bind_rows(r,b)
  p <- ggplot(tif_df, aes(theta, test_info, color = model)) +
    annotate("rect", xmin = 0, xmax = 2, ymin = -Inf, ymax = Inf, fill = "#ecfeff", alpha = 0.5) +
    geom_line(size=1.1) + theme(legend.position="bottom") +
    labs(title="Test information overlay", x=expression(theta), y="Information")
  ggsave("kit/docs/exhibits/fig_tif_overlay.png", p, width=9, height=6, dpi=200)
}

