# Container build and runtime

The application follows the Container-as-a-Function model: declared files are
mounted read-only at `/data`, the caller supplies canonical CLI controls, and
results are written only to `/output`.

## Build

```bash
container/build_docker.sh expression-heatmap:local
```

The build explicitly targets `linux/amd64`, the canonical Biowulf and AWS
Fargate architecture. Apple Silicon hosts may use Docker emulation during local
development.

## Validate

```bash
container/smoke_test.sh expression-heatmap:local
container/parity_test.sh expression-heatmap:local /path/to/OMIX/modules/OMIX-Expression-Heatmap
```

The parity test runs the same fixture through the standalone and pinned
canonical OMIX paths, then compares their heatmap, displayed matrix, and
summary byte-for-byte.

## Published image

```text
ghcr.io/nidap-community/expression-heatmap@sha256:565dd7cd5117eb062d2f10b96bf6725e63f9332782f61e2c0e45629bec3b58d4
```

Use the digest, rather than a mutable tag, for deployment. Convert this OCI
image to an Apptainer/Singularity `.sif` for HPC use; do not commit `.sif`
files to Git.
