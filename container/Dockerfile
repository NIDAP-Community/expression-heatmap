# syntax=docker/dockerfile:1
# Application image derived from the reviewed OMIX visualization runtime.
# The immutable digest, rather than a mutable tag, is the runtime baseline.
ARG BASE_IMAGE=ghcr.io/nidap-community/omix-r-visualization@sha256:d0c00bf328a6a4897c243472db742860d20f7f700d7aab3bbe44dd96a7d5a842
FROM ${BASE_IMAGE}

WORKDIR /app

COPY R/ R/
COPY schemas/ schemas/
COPY scripts/ scripts/
COPY test_data/ test_data/
COPY module.yml entrypoint.R OMIX_MODULE_SOURCE.md renv.lock ./

ARG VCS_REF=unknown
ARG BUILD_DATE=unknown
LABEL org.opencontainers.image.title="expression-heatmap" \
      org.opencontainers.image.description="Portable expression-heatmap component derived from OMIX" \
      org.opencontainers.image.source="https://github.com/NIDAP-Community/expression-heatmap" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.base.name="ghcr.io/nidap-community/omix-r-visualization@sha256:d0c00bf328a6a4897c243472db742860d20f7f700d7aab3bbe44dd96a7d5a842" \
      org.opencontainers.image.created="${BUILD_DATE}"

RUN mkdir -p /data /output \
    && useradd --create-home --uid 10001 --shell /usr/sbin/nologin expressionheatmap \
    && chown --recursive expressionheatmap:expressionheatmap /app /data /output

ENV EXPRESSION_HEATMAP_IMAGE_REVISION=${VCS_REF} \
    EXPRESSION_HEATMAP_OMIX_SOURCE_COMMIT=f53dd7670d161b50427b0446ec48b8ae8d54f56f \
    EXPRESSION_HEATMAP_BASE_IMAGE=ghcr.io/nidap-community/omix-r-visualization@sha256:d0c00bf328a6a4897c243472db742860d20f7f700d7aab3bbe44dd96a7d5a842

USER expressionheatmap
ENTRYPOINT ["Rscript", "--vanilla", "/app/entrypoint.R"]
CMD ["--help"]
