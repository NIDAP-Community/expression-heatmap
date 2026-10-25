#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(CDPATH= cd -- "${script_dir}/.." && pwd)"
image="${1:-expression-heatmap:local}"
smoke_root="$(mktemp -d "${TMPDIR:-/tmp}/expression-heatmap-smoke.XXXXXX")"
output_dir="${smoke_root}/output"

"${script_dir}/run_docker.sh" "${image}" "${project_dir}/test_data" "${output_dir}" \
  --expression_matrix /data/expression_matrix.csv \
  --sample_metadata /data/sample_metadata.csv \
  --group_columns Group,Batch \
  --include_all_genes true \
  --filter_top_genes_by_variance false \
  --heatmap_title "Smoke test heatmap" \
  --output_dir /output

for artifact in \
  expression_heatmap.png \
  expression_heatmap_matrix.csv \
  expression_heatmap_run_summary.txt \
  figures/expression_heatmap.png \
  tables/expression_heatmap_matrix.csv \
  logs/expression_heatmap_run_summary.txt \
  logs/sessionInfo.txt \
  RUN_METADATA.md \
  run_manifest.json; do
  test -s "${output_dir}/${artifact}" || { printf 'Missing smoke artifact: %s\n' "${artifact}" >&2; exit 1; }
done
grep -q 'Completed successfully.' "${output_dir}/RUN_METADATA.md"
grep -q '"status": "completed"' "${output_dir}/run_manifest.json"
printf 'Expression Heatmap container smoke test passed: %s\n' "${output_dir}"
