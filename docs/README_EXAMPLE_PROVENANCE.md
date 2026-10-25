# TCGA-BRCA README example provenance

- Source: cBioPortal Breast Invasive Carcinoma (TCGA, PanCancer Atlas) study `brca_tcga_pan_can_atlas_2018`.
- Molecular profile: `brca_tcga_pan_can_atlas_2018_rna_seq_v2_mrna` (batch-normalized RSEM expression).
- Snapshot date: 2026-10-25.
- Scope: 16 public primary-tumor samples and 12 named breast-cancer genes.
- Annotation: patient-level `SUBTYPE` value paired to its single listed sample.
- Transformation: `log2(RSEM + 1)` before rendering; the application additionally row-standardizes values for its default heatmap display.
- This compact example is for visualization documentation only, not cohort-wide inference.
