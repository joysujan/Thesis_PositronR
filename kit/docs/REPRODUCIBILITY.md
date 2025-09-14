# Reproducibility guide

Quick checks:
- Run: Rscript kit/code/run_example.R to produce kit/examples/example_scored_output.csv.
- Regenerate exhibits: source('kit/code/recreate_exhibits.R') if input CSVs are present.

Environment and assets:
- See kit/docs/environment.txt for R/mirt versions and kit/docs/checksums_sha256.csv for asset hashes.
- The release manifest (kit/docs/release_manifest.yml) pins versions and the default ROC cut.

Validation:
- Use the package validator (validate_on_sample) on any dataset with dQ1S..dQ21D and the 15 short-form items to export R^2/MAE/RMSE, confusion, and decile errors.
