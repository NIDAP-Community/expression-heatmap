#!/usr/bin/env bash
set -euo pipefail

if [[ "$#" -ne 2 ]]; then
  printf '%s\n' 'Usage: container/parity_test.sh <application-image> <canonical-omix-module-dir>' >&2
  exit 2
fi

script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(CDPATH= cd -- "${script_dir}/.." && pwd)"
application_image="$1"
canonical_module_dir="$2"
runtime_image="${EXPRESSION_HEATMAP_CANONICAL_RUNTIME:-ghcr.io/nidap-community/omix-r-visualization@sha256:d0c00bf328a6a4897c243472db742860d20f7f700d7aab3bbe44dd96a7d5a842}"
test -d "${canonical_module_dir}" || { printf 'Canonical module directory does not exist: %s\n' "${canonical_module_dir}" >&2; exit 2; }

parity_root="$(mktemp -d "${TMPDIR:-/tmp}/expression-heatmap-parity.XXXXXX")"
standalone_output="${parity_root}/standalone"
canonical_output="${parity_root}/canonical"
mkdir -p "${canonical_output}"

"${script_dir}/run_docker.sh" "${application_image}" "${project_dir}/test_data" "${standalone_output}" \
  --expression_matrix /data/expression_matrix.csv --sample_metadata /data/sample_metadata.csv \
  --group_columns Group,Batch --include_all_genes true --filter_top_genes_by_variance false --output_dir /output

docker run --rm --platform "${DOCKER_PLATFORM:-linux/amd64}" --workdir /output \
  --user "$(id -u):$(id -g)" \
  --mount "type=bind,src=$(CDPATH= cd -- "${canonical_module_dir}" && pwd -P),dst=/omix/OMIX-Expression-Heatmap,readonly" \
  --mount "type=bind,src=${project_dir}/test_data,dst=/data,readonly" \
  --mount "type=bind,src=${canonical_output},dst=/output" \
  --entrypoint Rscript "${runtime_image}" --vanilla /omix/OMIX-Expression-Heatmap/scripts/run_expression_heatmap.R \
  --expression_matrix /data/expression_matrix.csv --sample_metadata /data/sample_metadata.csv \
  --group_columns Group,Batch --include_all_genes true --filter_top_genes_by_variance false --output_dir /output

cmp "${standalone_output}/expression_heatmap_matrix.csv" "${canonical_output}/expression_heatmap_matrix.csv"
cmp "${standalone_output}/expression_heatmap_run_summary.txt" "${canonical_output}/expression_heatmap_run_summary.txt"
cmp "${standalone_output}/expression_heatmap.png" "${canonical_output}/expression_heatmap.png"
printf 'Canonical/standalone Expression Heatmap parity passed: %s\n' "${parity_root}"
