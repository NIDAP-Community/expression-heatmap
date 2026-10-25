# Canonical OMIX Module Source

## Pinned source snapshot

| Item | Value |
| --- | --- |
| Canonical module | `OMIX-Expression-Heatmap` |
| Canonical path | `modules/OMIX-Expression-Heatmap/` |
| OMIX source commit | `f53dd7670d161b50427b0446ec48b8ae8d54f56f` |
| Module version | `0.4.0` |
| Interface version | `1` |
| Module lifecycle | `development` |
| Runtime profile | `r-visualization` |

This repository is a pinned export of the canonical OMIX module. The copied
scientific implementation and portable interface must remain byte-identical to
the source snapshot. Scientific or reusable-interface changes belong in OMIX
first; this repository may add only application glue, packaging, validation,
and deployment documentation.

## Imported files

| Canonical file | Repository copy | SHA-256 |
| --- | --- | --- |
| `R/OMIX_Expression_Heatmap.R` | `R/OMIX_Expression_Heatmap.R` | `bed736c57db599334e8050dca8a971f891cf2b463a77a93aa83c74a22d0d4ba3` |
| `scripts/run_expression_heatmap.R` | `scripts/run_expression_heatmap.R` | `488fc873574016568066aabf910a061468264c84ab9d1d0c6d3da8ce2cc7ecbc` |
| `schemas/interface.yml` | `schemas/interface.yml` | `3cbb2bb0d3b4ac172cb9466260318913913d12aef6f72452d9b404b7aada9b5d` |
| `module.yml` | `module.yml` | `38e344643401ef8279ace74e9509b1190eaa51aede636e6acf2c8cec932a2713` |
| `starter-environments/r-visualization/renv.lock` | `renv.lock` | `43bcc21cd8813c42c50d5cd42f528bcb8ad7ce9124522bff20bb01a17680d1c1` |

## Runtime source

```text
ghcr.io/nidap-community/omix-r-visualization@sha256:d0c00bf328a6a4897c243472db742860d20f7f700d7aab3bbe44dd96a7d5a842
```

The pinned `r-visualization` v3 runtime supplies R 4.4.3 and the required
Bioconductor `ComplexHeatmap` 2.22.0 closure. The standalone image needs its
own build, smoke test, and immutable published digest before OncoChat uses it.
