# Decision Log

## 2026-10-25 — Canonical export and runtime baseline

The standalone application is pinned to OMIX commit
`f53dd7670d161b50427b0446ec48b8ae8d54f56f`, retaining the canonical
Expression Heatmap code and interface byte-for-byte. Its base runtime is the
verified OMIX `r-visualization` v3 immutable digest documented in
`OMIX_MODULE_SOURCE.md`.

## 2026-10-25 — Application boundary

The application accepts only staged normalized continuous expression and
sample metadata. Cohort selection, database extraction, normalization, and
derivation of annotations such as mutation status or ESTIMATE scores remain
upstream responsibilities of OncoChat or another workflow component.
