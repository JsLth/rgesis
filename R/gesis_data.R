#' Download survey data
#' @description
#' Downloads survey data from GESIS given a hit or a dataset ID. To download
#' data, the session must be authenticated using \code{\link{gesis_auth}}.
#'
#' @param hit Object of class \code{gesis_hit} as returned by
#' \code{\link{gesis_search}} and \code{gesis_get} or dataset ID. If a dataset ID
#' is passed, the function performs a call to \code{\link{gesis_get}}.
#' @param download_purpose Purpose for the use of the research data as
#' demanded by GESIS. Must be one of \code{"final_thesis"},
#' \code{"commercial_research"}, \code{"non_scientific"},
#' \code{"further_education"}, \code{"scientific_research"}, \code{"studies"},
#' or \code{"lecturer"}.
#' @param path Path where the downloaded file should be stored. Can be path
#' to a directory or a file. If a directory path, it is attempted to infer the
#' file name from the file to be downloaded. If this is not possible, the file
#' is stored in a file called \code{gesis} with no file extension. If a file
#' path is passed, the file is directly downloaded to this path. Defaults to
#' a temporary directory path.
#' @param type Type of data to download. Must be one of \code{"dataset"},
#' \code{"questionnaire"}, \code{"codebook"}, \code{"otherdocs"},
#' or \code{"uncategorized"}. A file type is "uncategorized" if it is falls
#' under none of the other file types. Defaults to \code{"dataset"}. A list of
#' available data types for a given record can be retrieved using
#' \code{\link{gesis_file_types}}.
#' @param select Character string to select a data file in case multiple files
#' are available for the selected data type. The character string is
#' matched against the file label using regular expressions. This argument
#' can also be used to match explicitly for file extensions, e.g.
#' \code{"\\\\.sav"} or \code{"\\\\.dat"}. A list of file labels for a given
#' record can be retrieved using \code{\link{gesis_files}}. If \code{NULL},
#' multiple files are detected, and the session is interactive, prompts the
#' user to select a file. Defaults to \code{NULL}.
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
#' if (FALSE) {
#' # retrieve a search record to pass on to gesis_data()
#' hit <- gesis_search(
#'   "allbus",
#'   publication_year = c(2019, 2020),
#'   type = "research_data"
#' )
#'
#' # in interactive mode, the function can be run without arguments
#' path <- gesis_data(hit[[1]])
#'
#' # in other cases, certain arguments should be provided
#' path <- gesis_data(hit[[1]], download_purpose = "non_scientific", select = "\\.sav")
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
#' }
gesis_data <- function(hit,
                       download_purpose = NULL,
                       path = tempdir(),
                       type = "dataset",
                       select = NULL,
                       prompt = interactive()) {
  assert_class(hit, c("character", "gesis_hit"))
  assert_vector(path, "character", size = 1)
  assert_vector(select, "character", size = 1, null = TRUE)
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
  if (is.character(hit)) {
    hit <- gesis_get(hit)
  }

  links <- get_links_from_hit(hit, type = type)
  label_field <- if ("label_en" %in% names(links)) "label_en" else "label"
  labels <- vapply(links, FUN.VALUE = character(1), "[[", label_field)

  # if multiple links are found, select one using regex if provided
  if (length(links) > 1 && !is.null(select)) {
    choice <- grepl(select, labels)
    links <- links[choice]
  }

  # if there's still multiple links, ask manually if possible
  if (length(links) > 1 && interactive() && prompt) {
    cli::cli_inform(c(
      "i" = "Multiple data files have been found.",
      "i" = "Please select a file to download from the selection below."
    ))
    choice <- utils::menu(labels)
    links <- links[labels == labels[choice]]
  }

  # if no file matches the select regex, fail
  if (!length(links)) {
    rg_stop("`select` did not match any {.field {type}} for record ID {.val {attr(hit, 'id')}}.")
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
