#!/usr/bin/env Rscript

# Generate the small public TCGA-BRCA README example from a saved cBioPortal
# molecular-data response.  The script is intentionally separate from the
# application: it documents the figure provenance and is not a workflow input.

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) {
  stop("Usage: generate_tcga_brca_example.R <cBioPortal-response.json> <output-directory>")
}
json_path <- normalizePath(args[[1L]], mustWork = TRUE)
output_dir <- args[[2L]]
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
output_dir <- normalizePath(output_dir, mustWork = TRUE)

gene_symbols <- c(
  `2099` = "ESR1", `2064` = "ERBB2", `5241` = "PGR", `2625` = "GATA3",
  `3169` = "FOXA1", `3852` = "KRT5", `3861` = "KRT14", `4288` = "MKI67",
  `1956` = "EGFR", `672` = "BRCA1", `675` = "BRCA2", `7157` = "TP53"
)
sample_order <- c(
  "TCGA-3C-AAAU-01", "TCGA-3C-AALI-01", "TCGA-3C-AALJ-01", "TCGA-3C-AALK-01",
  "TCGA-4H-AAAK-01", "TCGA-5L-AAT0-01", "TCGA-5T-A9QA-01", "TCGA-A1-A0SB-01",
  "TCGA-A1-A0SD-01", "TCGA-A1-A0SE-01", "TCGA-A1-A0SF-01", "TCGA-A1-A0SG-01",
  "TCGA-A1-A0SH-01", "TCGA-A1-A0SI-01", "TCGA-A1-A0SJ-01", "TCGA-A1-A0SK-01"
)
subtype <- c(
  "BRCA_LumA", "BRCA_Her2", "BRCA_LumB", "BRCA_LumA", "BRCA_LumA", "BRCA_LumA",
  "BRCA_LumB", "BRCA_Normal", "BRCA_LumA", "BRCA_LumA", "BRCA_LumA", "BRCA_LumA",
  "BRCA_LumA", "BRCA_LumB", "BRCA_LumA", "BRCA_Basal"
)

values <- jsonlite::fromJSON(json_path)
values$Gene <- unname(gene_symbols[as.character(values$entrezGeneId)])
if (anyNA(values$Gene)) stop("The response contains an unexpected Entrez gene ID.")
if (!all(sample_order %in% values$sampleId)) stop("The response is missing requested samples.")

matrix <- stats::reshape(
  values[, c("Gene", "sampleId", "value")],
  idvar = "Gene", timevar = "sampleId", direction = "wide"
)
names(matrix) <- sub("^value\\.", "", names(matrix))
matrix <- matrix[match(unname(gene_symbols), matrix$Gene), c("Gene", sample_order)]
matrix[, sample_order] <- lapply(matrix[, sample_order, drop = FALSE], function(x) log2(as.numeric(x) + 1))
metadata <- data.frame(Sample = sample_order, Subtype = subtype, stringsAsFactors = FALSE)

utils::write.csv(matrix, file.path(output_dir, "expression_matrix.csv"), row.names = FALSE, quote = FALSE)
utils::write.csv(metadata, file.path(output_dir, "sample_metadata.csv"), row.names = FALSE, quote = FALSE)
writeLines(c(
  "# TCGA-BRCA README example provenance", "",
  "- Source: cBioPortal Breast Invasive Carcinoma (TCGA, PanCancer Atlas) study `brca_tcga_pan_can_atlas_2018`.",
  "- Molecular profile: `brca_tcga_pan_can_atlas_2018_rna_seq_v2_mrna` (batch-normalized RSEM expression).",
  "- Snapshot date: 2026-10-25.",
  "- Scope: 16 public primary-tumor samples and 12 named breast-cancer genes.",
  "- Annotation: patient-level `SUBTYPE` value paired to its single listed sample.",
  "- Transformation: `log2(RSEM + 1)` before rendering; the application additionally row-standardizes values for its default heatmap display.",
  "- This compact example is for visualization documentation only, not cohort-wide inference."
), file.path(output_dir, "README_DATA_PROVENANCE.md"))
