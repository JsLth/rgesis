#' Download survey data
#' @description
#' Downloads survey data from GESIS given a record or a dataset ID. To download
#' data, the session must be authenticated using \code{\link{gesis_auth}}.
#'
#' By downloading data from the GESIS data archive, you agree to its
#' \href{https://www.gesis.org/fileadmin/upload/dienstleistung/daten/umfragedaten/_bgordnung_bestellen/2023-06-30_Usage_regulations.pdf}{terms of use}.
#' This function is intended to be used for singular, programmatic access to
#' survey datasets. Please refrain from using it for large-scale batch
#' downloads.
#'
#' @param record Object of class \code{gesis_record} as returned by
#' \code{\link{gesis_search}} and \code{gesis_get} or dataset ID. If a dataset ID
#' is passed, the function performs a call to \code{\link{gesis_get}}.
#' @param download_purpose Purpose for the use of the research data. You are
#' required to use the downloaded data solely for the specified purpose
#' (see also the
#' \href{https://www.gesis.org/fileadmin/upload/dienstleistung/daten/umfragedaten/_bgordnung_bestellen/2023-06-30_Usage_regulations.pdf}{terms of use}).
#' The following values are supported:
#'
#' `r rd_purposes()`
#' @param path Path where the downloaded file should be stored. Can be path
#' to a directory or a file. If a directory path, it is attempted to infer the
#' file name from the file to be downloaded. If this is not possible, the file
#' is stored in a file called \code{gesis} with no file extension. If a file
#' path is passed, the file is directly downloaded to this path. Defaults to
#' a temporary directory path.
#' @param type Type of data to download. The following values are supported:
#'
#' \itemize{
#'  \item{\code{dataset}: Survey dataset, usually in a Stata or SPSS data format}
#'  \item{\code{questionnaire}: Survey questionnaire, usually in PDF format}
#'  \item{\code{codebook}: Survey codebook, usually in PDF format}
#'  \item{\code{otherdocs}: Other files like READMEs, method
#'  reports, or variable lists, usually in PDF format}
#'  \item{\code{uncategorized}: Other files that are not categorized, usually
#'  used for external links to full texts (DOI, URN)}
#' }
#'
#' Defaults to \code{"dataset"} because downloading PDF or HTML files rarely
#' makes sense in R. A list of available data types for a given record can be
#' retrieved using \code{\link{gesis_file_types}}.
#' @param select Character vector to select a data file in case multiple files
#' are available for the selected data type. The character string is
#' matched against the file label using regular expressions. This argument
#' can also be used to match explicitly for file extensions, e.g.
#' \code{"\\\\.sav"} or \code{"\\\\.dat"}. Can also be of length > 1 in which
#' case the regular expressions are matched in the order of their index
#' positions. A list of file labels for a given record can be retrieved using
#' \code{\link{gesis_files}}. If \code{NULL}, multiple files are detected, and
#' the session is interactive, prompts the user to select a file. Defaults to
#' \code{NULL}.
#' @param prompt If \code{TRUE}, allows the function to open an interactive
#' prompt in case multiple files are found and \code{select} is either
#' \code{NULL} or fails to select a file unambiguously. If \code{FALSE},
#' throws an error in such a case. Defaults to \code{TRUE} if run in an
#' interactive session.
#'
#' @returns The path to the downloaded file. Depending on the selected file,
#' there are different ways to read the file contents. Traditionally, data
#' files are offered in Stata and SPSS file formats and can be read using the
#' \href{https://haven.tidyverse.org/}{haven} package.
#'
#' @details
#' Access and refresh tokens are automatically attached to the requests sent
#' if possible. This is done only for URLs pointing to the domain gesis.org
#' to avoid sending authentication information to other domains.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # retrieve a search record to pass on to gesis_data()
#' record <- gesis_search(
#'   "allbus",
#'   publication_year = c(2019, 2020),
#'   type = "research_data"
#' )
#'
#' # in interactive mode, the function can be run without arguments
#' path <- gesis_data(record[[1]])
#'
#' # in other cases, certain arguments should be provided
#' path <- gesis_data(record[[1]], download_purpose = "non_scientific", select = "\\.sav")
#'
#' # you can also simply pass a dataset ID
#' path <- gesis_data("ZA3753", select = "\\.por")
#'
#' # data files must be read using other tools and packages, e.g. haven
#' haven::read_por(path)
#'
#' # ... or pdftools
#' path <- gesis_data("ZA3753", select = "fb\\.pdf", type = "questionnaire")
#' pdftools::pdf_text(path)
#'
#' # In some cases, a single selection regex might be difficult to work
#' # with, e.g., if multiple files with the same format exist.
#' # In this case, you may pass multiple regular expressions which are
#' # evaluated back by back
#' gesis_data(
#'   "ZA7716",
#'   select = c("\\.sav", "main"),
#'   download_purpose = "non_scientific"
#' )}
gesis_data <- function(record,
                       download_purpose = NULL,
                       path = tempdir(),
                       type = "dataset",
                       select = NULL,
                       prompt = interactive()) {
  assert_class(record, c("character", "gesis_record"))
  assert_vector(path, "character", size = 1)
  assert_vector(select, "character", null = TRUE)
  assert_flag(prompt)

  download_purpose <- download_purpose %||% getOption("gesis_download_purpose")
  if (is.null(download_purpose) && prompt) {
    cli::cli_inform(c("i" = "Please specifiy a purpose for the use of the research data."))
    choice <- utils::menu(purposes)
    download_purpose <- names(purposes[choice])
  }

  download_purpose <- match.arg(download_purpose, choices = names(purposes))
  type <- match.arg(type, choices = file_types)

  # if a character is provided, interpret it as an id and look it up
  if (is.character(record)) {
    record <- gesis_get(record)
  }

  links <- get_links_from_record(record, type = type)
  label_field <- if ("label_en" %in% names(links)) "label_en" else "label"
  labels <- vapply(links, FUN.VALUE = character(1), "[[", label_field)

  # if multiple links are found, select one using regex if provided
  if (length(links) > 1 && !is.null(select)) {
    for (expr in select) {
      choice <- grepl(expr, labels)
      labels <- labels[choice]
      links <- links[choice]

      if (length(links) == 1) break
    }
  }

  # if there's still multiple links, ask manually if possible
  if (length(links) > 1 && prompt) {
    add <- ifelse(!is.null(select), " containing the expression {.val {select}}", "")

    cli::cli_inform(c(
      "i" = sprintf("Multiple data files have been found%s.", as.character(add)),
      "i" = "Please select a file to download from the selection below."
    ))

    choice <- utils::menu(labels)
    links <- links[labels == labels[choice]]
  }

  # if no file matches the select regex, fail
  if (!length(links)) {
    rg_stop("`select` did not match any {.field {type}} for record ID {.val {attr(record, 'id')}}.")
  }

  # if there's still multiple links, fail
  if (length(links) > 1) {
    rg_stop(c(
      "Multiple data files have been found.",
      "i" = paste(
        "Please select a file by passing a `select`",
        "string or by setting `prompt = TRUE`."
      )
    ))
  }

  # if a directory is provided, construct the file name
  # otherwise adopt the provided file name
  if (is_dir(path)) {
    file <- labels[choice]
    file <- filename_from_label(file) %|||% basename(tempfile(pattern = "gesis"))
    path <- file.path(path, file)
  }

  url <- links[[1]]$url %||% links[[1]]$link
  resp <- gesis_download(url, path = path, purpose = download_purpose)
  unclass(normalizePath(resp$body, "/"))
}


gesis_download <- function(url, path, purpose) {
  req <- httr2::request(url)
  req <- httr2::req_url_query(req, download_purpose = purpose)
  req <- httr2::req_error(req, body = function(resp) {
    if (resp$status_code == 401) {
      content <- httr2::resp_body_json(resp)
      content$detail
    }
  })

  # only add auth info when hostname is gesis.org
  if (is_gesis_url(url)) {
    req <- req_add_auth(req)
  }

  httr2::req_perform(req, path = path)
}


is_gesis_url <- function(url) {
  url <- httr2::url_parse(url)
  grepl("gesis.org", url$hostname, fixed = TRUE)
}


purposes <- c(
  final_thesis = "for final thesis of the study programme (e.g. Bachelor/Master thesis)",
  commercial_research = "for research with a commercial mission",
  non_scientific = "for non-scientific purposes",
  further_education = "for further education and qualification",
  scientific_research = "for scientific research (incl. doctorate)",
  studies = "in the course of my studies",
  lecturer = "in a course as a lecturer"
)


file_types <- c(
  "dataset", "questionnaire", "codebook", "otherdocs", "uncategorized"
)


rd_purposes <- function() {
  plst <- lapply(names(purposes), function(p) {
    sprintf(" \\item{\\code{%s}: %s}", p, purposes[p])
  })

  sprintf("\\itemize{\n%s\n}", paste(plst, collapse = "\n"))
}
