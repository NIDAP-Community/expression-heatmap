# Expression Heatmap

`expression-heatmap` is a containerized R application for rendering annotated
expression heatmaps from a normalized continuous feature-by-sample matrix and
matching sample metadata. It is designed for command-line, HPC, and OncoChat
use: an application layer stages declared inputs under `/data`, the container
writes a self-describing result bundle to `/output`, and no database
credentials enter the image.

It is a pinned derivation of the canonical [OMIX Expression
Heatmap](https://github.com/NIDAP-Community/OMIX/tree/main/modules/OMIX-Expression-Heatmap)
module. The canonical scientific implementation and interface are retained
byte-for-byte; see [OMIX_MODULE_SOURCE.md](OMIX_MODULE_SOURCE.md).

## Input contract

Use continuous values appropriate for visualization: normalized bulk
expression, batch-corrected expression, or single-cell-derived pseudobulk or
mean-expression values. Do **not** supply raw counts, Seurat objects, or a
database connection. Rows are features and columns are samples. Duplicate
feature identifiers are averaged by the canonical module.

The metadata table has one row per displayed sample. Its sample-ID column must
match expression-matrix column names. Any requested annotation fields—for
example molecular subtype, mutation status, ESTIMATE score group, or batch—are
prepared upstream and supplied as metadata columns.

## Quick start

Build a local AMD64 image:

```bash
container/build_docker.sh expression-heatmap:local
```

Run with explicit, read-only input and writable output mounts:

```bash
docker run --rm --platform linux/amd64 \
  -v /path/to/input:/data:ro \
  -v /path/to/output:/output \
  expression-heatmap:local \
  --expression_matrix /data/expression_matrix.tsv \
  --sample_metadata /data/sample_metadata.tsv \
  --gene_column Gene \
  --sample_name_column Sample \
  --sample_label_column Sample \
  --group_columns Subtype,Batch \
  --top_genes_by_variance_to_include 100 \
  --output_dir /output
```

Use the supplied wrapper for the same CAF mount contract:

```bash
container/run_docker.sh expression-heatmap:local /path/to/input /path/to/output \
  --expression_matrix /data/expression_matrix.tsv \
  --sample_metadata /data/sample_metadata.tsv \
  --group_columns Subtype \
  --output_dir /output
```

## Core controls

| Control | Default | Purpose |
| --- | --- | --- |
| `--top_genes_by_variance_to_include` | `500` | Highest-variance features to display. |
| `--specific_genes_to_include` | `None` | Space-separated extra feature IDs retained with variable features. |
| `--include_all_genes` | `false` | Display the complete matrix; set `--filter_top_genes_by_variance false` at the same time. |
| `--group_columns` | empty | Comma-separated metadata columns rendered as top annotations. |
| `--center_and_rescale` | `true` | Row-standardize selected features before rendering. |
| `--cluster_samples` | `true` | Unsupervised sample clustering. Choose exactly one sample-ordering mode. |
| `--arrange_sample_columns` | `false` | Group columns by annotation instead of clustering. |
| `--order_by_gene_expression` | `false` | Order columns by one plotted feature. |
| `--heatmap_color_scheme` | `Bu Yl Rd` | One of the canonical palettes in `schemas/interface.yml`. |
| `--display_gene_names` | `auto` | Show labels for focused panels while avoiding crowding dense maps. |
| `--output_dir` | required by application | Writable result directory, normally `/output`. |

The complete canonical parameter set and defaults are in
[schemas/interface.yml](schemas/interface.yml).

## Results

The canonical files remain at the chosen output root for command-line
compatibility. The wrapper also produces stable application paths:

```text
output/
├── expression_heatmap.png
├── expression_heatmap_matrix.csv
├── expression_heatmap_run_summary.txt
├── figures/expression_heatmap.png
├── tables/expression_heatmap_matrix.csv
├── logs/
│   ├── expression_heatmap_run_summary.txt
│   └── sessionInfo.txt
├── RUN_METADATA.md
└── run_manifest.json
```

The matrix under `tables/` is the exact matrix plotted after canonical
duplicate-feature aggregation, selection, and optional row standardization.

## OncoChat integration

OncoChat chooses the cohort, materializes the declared normalized-expression
and metadata tables, then invokes a released image by immutable digest. It
does not pass database credentials into this image. See
[docs/oncochat_adapter_contract.md](docs/oncochat_adapter_contract.md) and
[schemas/application_interface.yml](schemas/application_interface.yml).

## Validation

```bash
container/build_docker.sh expression-heatmap:local
container/smoke_test.sh expression-heatmap:local
container/parity_test.sh expression-heatmap:local /path/to/OMIX/modules/OMIX-Expression-Heatmap
```

The parity test verifies that canonical and standalone runs produce identical
heatmaps, displayed matrices, and canonical summaries for the same fixture.

## HPC use

The image targets `linux/amd64`. Once a versioned GHCR image is published, it
can be pulled into Apptainer or Singularity:

```bash
apptainer pull expression-heatmap.sif \
  docker://ghcr.io/nidap-community/expression-heatmap:VERSION
```

Use `container/run_apptainer.sh` to bind input to `/data` and results to
`/output` with the same contract as Docker.
