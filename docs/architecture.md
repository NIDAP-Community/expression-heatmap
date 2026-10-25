# Architecture

## Purpose

Expression Heatmap is a Container-as-a-Function (CAF) application for
rendering clustered, annotated heatmaps from normalized continuous
feature-by-sample matrices. It is suitable for local command-line use, HPC,
and OncoChat orchestration.

The repository preserves the canonical OMIX scientific code under `R/`,
`scripts/`, `schemas/`, and `module.yml`. `entrypoint.R` is deliberately
limited to invoking that CLI and producing the stable application result
bundle. It does not alter filtering, duplicate-feature aggregation, row
standardization, sample ordering, clustering, or rendering defaults.

## Execution flow

1. The caller stages a normalized continuous expression matrix and matching
   sample metadata under `/data`.
2. The container receives explicit CLI controls and an explicit output path.
3. `entrypoint.R` invokes the canonical OMIX CLI unchanged.
4. The canonical CLI writes the heatmap, displayed matrix, and run summary.
5. The wrapper copies those canonical files into stable `figures/`, `tables/`,
   and `logs/` paths and writes run provenance.

## Runtime and portability

- Target architecture: `linux/amd64`.
- Base image: a pinned OMIX `r-visualization` v3 OCI digest.
- Inputs: read-only `/data` mount.
- Outputs: writable `/output` mount.
- No database credentials, patient data, or hidden state are built into the
  image.

The image is a runtime artifact; SIF files are derived from the OCI image for
Apptainer/Singularity use and are never committed to Git.
