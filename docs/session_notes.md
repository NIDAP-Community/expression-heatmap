# Session Notes

## 2026-10-25 — Initial standalone application

- Derived from canonical OMIX commit `f53dd7670d161b50427b0446ec48b8ae8d54f56f`.
- Local AMD64 build, smoke test, and canonical parity test passed.
- GitHub Actions validation run `40231421297` passed pinned-export, build,
  smoke, and parity checks.
- Published the repository-owned OCI image from application commit `a283a95`:
  `ghcr.io/nidap-community/expression-heatmap@sha256:565dd7cd5117eb062d2f10b96bf6725e63f9332782f61e2c0e45629bec3b58d4`.
- The public README includes a visually inspected compact TCGA-BRCA example;
  its source and transformation are documented in `README_EXAMPLE_PROVENANCE.md`.
