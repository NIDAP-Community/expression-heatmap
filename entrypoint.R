#!/usr/bin/env Rscript

# Application wrapper only.  The copied OMIX files own heatmap selection,
# transformation, clustering, and rendering.  This layer establishes the
# container result-bundle contract after a successful canonical invocation.

args <- commandArgs(trailingOnly = TRUE)
canonical_cli <- normalizePath(file.path("scripts", "run_expression_heatmap.R"), mustWork = TRUE)

option_value <- function(option_name, values) {
  exact <- which(values == option_name)
  if (length(exact) == 1L && exact < length(values)) return(values[[exact + 1L]])
  prefix <- paste0(option_name, "=")
  inline <- values[startsWith(values, prefix)]
  if (length(inline) == 1L) return(substring(inline, nchar(prefix) + 1L))
  NULL
}

write_result_bundle <- function(output_dir, arguments) {
  artifacts <- data.frame(
    role = c("Expression heatmap", "Displayed expression matrix", "Canonical run summary"),
    source = file.path(output_dir, c(
      "expression_heatmap.png",
      "expression_heatmap_matrix.csv",
      "expression_heatmap_run_summary.txt"
    )),
    destination = c(
      "figures/expression_heatmap.png",
      "tables/expression_heatmap_matrix.csv",
      "logs/expression_heatmap_run_summary.txt"
    ),
    stringsAsFactors = FALSE
  )
  if (!all(file.exists(artifacts$source))) {
    stop("Canonical heatmap run completed without all expected artifacts.")
  }

  for (directory in unique(dirname(artifacts$destination))) {
    dir.create(file.path(output_dir, directory), recursive = TRUE, showWarnings = FALSE)
  }
  dir.create(file.path(output_dir, "logs"), recursive = TRUE, showWarnings = FALSE)
  for (index in seq_len(nrow(artifacts))) {
    if (!file.copy(artifacts$source[[index]], file.path(output_dir, artifacts$destination[[index]]), overwrite = TRUE)) {
      stop("Could not create stable application artifact: ", artifacts$role[[index]])
    }
  }
  capture.output(sessionInfo(), file = file.path(output_dir, "logs", "sessionInfo.txt"))

  input_options <- c("--expression_matrix", "--sample_metadata")
  input_paths <- vapply(input_options, function(option_name) {
    value <- option_value(option_name, arguments)
    if (is.null(value)) "" else value
  }, character(1L))
  names(input_paths) <- input_options
  input_paths <- input_paths[nzchar(input_paths)]
  input_manifest <- data.frame(
    option = names(input_paths),
    path = unname(input_paths),
    md5 = unname(tools::md5sum(unname(input_paths))),
    stringsAsFactors = FALSE
  )

  runtime_versions <- c(
    R = R.version.string,
    ComplexHeatmap = as.character(utils::packageVersion("ComplexHeatmap")),
    jsonlite = as.character(utils::packageVersion("jsonlite"))
  )
  application_revision <- Sys.getenv("EXPRESSION_HEATMAP_IMAGE_REVISION", "unknown")
  omix_source_commit <- Sys.getenv("EXPRESSION_HEATMAP_OMIX_SOURCE_COMMIT", "unknown")
  base_image <- Sys.getenv("EXPRESSION_HEATMAP_BASE_IMAGE", "unknown")
  timestamp <- format(Sys.time(), tz = "UTC", usetz = TRUE)

  metadata_lines <- c(
    "# Expression Heatmap Run Metadata", "", "## Status", "", "Completed successfully.",
    "", "## Provenance", "",
    paste("- Application revision:", application_revision),
    paste("- Canonical OMIX source commit:", omix_source_commit),
    "- Canonical OMIX module: OMIX-Expression-Heatmap (version 0.4.0; interface 1)",
    paste("- Pinned base image:", base_image),
    paste("- Completed UTC:", timestamp), "", "## Runtime", "",
    paste("-", names(runtime_versions), runtime_versions), "",
    "## Declared input artifacts", "", "| Option | Container path | MD5 |",
    "| --- | --- | --- |",
    paste0("| ", input_manifest$option, " | `", input_manifest$path, "` | `", input_manifest$md5, "` |"),
    "", "## Parameters", "", paste0("`", paste(arguments, collapse = " ` `"), "`"),
    "", "## Interpretation", "",
    "This is an exploratory research visualization, not clinical decision support."
  )
  writeLines(metadata_lines, file.path(output_dir, "RUN_METADATA.md"))

  manifest <- list(
    status = "completed",
    completed_utc = timestamp,
    application_revision = application_revision,
    canonical_omix_source_commit = omix_source_commit,
    base_image = base_image,
    artifacts = c(
      lapply(seq_len(nrow(artifacts)), function(index) {
        list(role = artifacts$role[[index]], path = artifacts$destination[[index]])
      }),
      list(list(role = "R session information", path = "logs/sessionInfo.txt"))
    ),
    input_artifacts = lapply(seq_len(nrow(input_manifest)), function(index) {
      list(option = input_manifest$option[[index]], path = input_manifest$path[[index]], md5 = input_manifest$md5[[index]])
    }),
    arguments = arguments,
    runtime = as.list(runtime_versions)
  )
  jsonlite::write_json(manifest, file.path(output_dir, "run_manifest.json"), auto_unbox = TRUE, pretty = TRUE)
}

if (any(args %in% c("--help", "-h"))) {
  quit(save = "no", status = system2(file.path(R.home("bin"), "Rscript"), c("--vanilla", canonical_cli, args)))
}

output_dir <- option_value("--output_dir", args)
if (is.null(output_dir) || !nzchar(output_dir)) {
  stop("The application requires --output_dir (normally /output in the container).")
}
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
output_dir <- normalizePath(output_dir, mustWork = TRUE)
output_index <- which(args == "--output_dir")
if (length(output_index) == 1L && output_index < length(args)) {
  args[[output_index + 1L]] <- output_dir
} else {
  inline_index <- which(startsWith(args, "--output_dir="))
  if (length(inline_index) == 1L) args[[inline_index]] <- paste0("--output_dir=", output_dir)
}

# Keep any incidental graphics-device state inside the declared writable output.
setwd(output_dir)
# `system2()` constructs a shell command on some R platforms. Quote each
# argument so free-text controls such as --heatmap_title keep embedded spaces.
status <- system2(
  file.path(R.home("bin"), "Rscript"),
  c("--vanilla", shQuote(canonical_cli), shQuote(args))
)
if (identical(as.integer(status), 0L)) {
  write_result_bundle(output_dir, args)
  unlink(file.path(output_dir, "Rplots.pdf"), force = TRUE)
}
quit(save = "no", status = as.integer(status))
