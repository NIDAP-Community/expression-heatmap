# OncoChat Adapter Contract

The OncoChat adapter stages bounded workflow artifacts under `/data` and
invokes a released `linux/amd64` image by immutable OCI digest. It never passes
database credentials, host paths, arbitrary shell flags, or unapproved source
tables into the image.

## Required staged artifacts

| Container path | Required form |
| --- | --- |
| `/data/expression_matrix.tsv` | Normalized, continuous feature-by-sample expression values. Raw counts, TPM-to-count conversions, Seurat objects, and database connections are not accepted by this visualization application. |
| `/data/sample_metadata.tsv` | One row per plotted sample. The chosen sample-ID column must match expression-matrix columns. It may contain approved display labels and requested annotation columns. |

The adapter must select the cohort and produce any molecular or clinical
annotation fields upstream. For example, mutation status, subtype, ESTIMATE
scores, or immune fractions are staged as ordinary metadata columns; the
heatmap application does not query or interpret the underlying source tables.

## Invocation requirements

- Mount `/data` read-only and `/output` writable.
- Pass `--expression_matrix`, `--sample_metadata`, and `--output_dir /output`.
- Expose only the canonical, bounded controls in `schemas/interface.yml`.
- Validate sample-ID alignment and that every requested `--group_columns`
  field is present before launch.
- Keep exactly one primary column-ordering mode enabled: cluster, arrange by
  groups, or order by an expression feature.

## Result handoff

On a zero exit status, consume `run_manifest.json`, `RUN_METADATA.md`, and:

| Stable path | Contents |
| --- | --- |
| `figures/expression_heatmap.png` | Rendered heatmap. |
| `tables/expression_heatmap_matrix.csv` | Exact matrix displayed after canonical selection and transformation. |
| `logs/expression_heatmap_run_summary.txt` | Canonical selected-sample and control record. |
| `logs/sessionInfo.txt` | Runtime package information. |

The application produces exploratory research visualizations only; it is not
clinical decision support.
