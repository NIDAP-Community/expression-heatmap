#!/usr/bin/env bash
set -euo pipefail

script_dir="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(CDPATH= cd -- "${script_dir}/.." && pwd)"
image_tag="${1:-expression-heatmap:local}"
vcs_ref="$(git -C "${project_dir}" rev-parse HEAD)"
build_date="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

docker buildx build \
  --file "${script_dir}/Dockerfile" \
  --load \
  --platform linux/amd64 \
  --tag "${image_tag}" \
  --build-arg "VCS_REF=${vcs_ref}" \
  --build-arg "BUILD_DATE=${build_date}" \
  "${project_dir}"
