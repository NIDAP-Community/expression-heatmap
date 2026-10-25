# Changelog

## 0.1.0 — 2026-10-25

- Created the standalone, containerized Expression Heatmap application from
  the pinned OMIX Expression Heatmap module at commit `f53dd767`.
- Added a CAF entrypoint, read-only `/data` and writable `/output` contract,
  stable result bundle, provenance, OCI labels, smoke test, parity test, and
  GitHub Actions validation.
- Pinned the verified OMIX `r-visualization` v3 base-image digest.
- Published the validated `linux/amd64` application image at
  `ghcr.io/nidap-community/expression-heatmap@sha256:565dd7cd5117eb062d2f10b96bf6725e63f9332782f61e2c0e45629bec3b58d4`.
