# Methods appendix

Model and scoring:
- 1D graded response model (GRM) fitted on 15 items; scoring uses mirt::fscores with method = 'EAP' and full.scores.SE for SEs. [Ref: mirt]
- Short-form theta is linearly mapped to the SEM latent (theta_cal) via a saved linker trained on joint data. [Ref: calibration]

Operating point and flag:
- Elevated flag uses ROC operating points; default cut = "Youden" (Youden) maximizing J = Sens + Spec − 1 under equal cost assumptions.
- Sensitivity-prioritized cut (e.g., Sens≥0.80) is available when false negatives are more costly.

Information and reliability:
- Report test information overlays vs baseline-21; marginal reliability follows rel(theta) = I(theta)/(I(theta)+1).

Legacy display:
- Approximate DASS-21 totals/categories via equipercentile or linear links are provided for communication only; do not use for decisions.

Limitations:
- Residual LD screens (e.g., Q3) are dataset dependent; thresholds are heuristic and should be contextualized.
- ROC cut selection should consider prevalence and decision costs in the deployment setting.
