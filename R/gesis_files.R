#' GESIS files
#' @description
#' Explore the files associated with a GESIS Search record. The output of this
#' function may guide you in selecting a file to download using
#' \code{\link{gesis_data}}.
#'
#' \code{gesis_file_types} gives an overview of the file categories, i.e.
#' datasets, questionnaires, codebooks or other documents, that are available
#' for a specific record.
#'
#' @inheritParams gesis_data
#' @returns \code{gesis_files} returns a list of class \code{gesis_file}
#' containing information about the file name, format, size, download URL, and
#' whether the file needs a login to download.
#'
#' \code{gesis_file_types} returns a character vector containing the file
#' types that are available. If \code{"none"}, files are available but not
#' categorized. If \code{NULL}, no files are available for download.
#'
#' @export
#'
#' @examples
#' \donttest{# check what file types are available
#' gesis_file_types("ZA3753")
#'
#' # show all dataset files for ALLBUS 1998
#' gesis_files("ZA3753")
#'
#' # show all of its questionnaire files
#' gesis_files("ZA3753", type = "questionnaire")
#'
#' # other record types can have files, too
#' type <- gesis_file_types("pretest-129")
#' hit <- gesis_files("pretest-129", type = "none")}
gesis_files <- function(hit, type = "dataset") {
  assert_class(hit, c("character", "gesis_hit"))
  type <- match.arg(type, choices = c(
    "dataset", "questionnaire", "codebook", "otherdocs", "uncategorized"
  ))

  if (is.character(hit)) {
    hit <- gesis_get(hit)
  }

  links <- get_links_from_hit(hit, type = type)
  class(links) <- "gesis_files"
  links
}


#' @rdname gesis_files
#' @export
gesis_file_types <- function(hit) {
  assert_class(hit, c("character", "gesis_hit"))

  if (is.character(hit)) {
    hit <- gesis_get(hit)
  }

  cats <- names(hit)
  cats <- cats[startsWith(cats, "links")]

  cats[cats %in% "links"] <- "uncategorized"
  gsub("^links_", "", cats) %empty% NULL
}


get_links_from_hit <- function(hit, type) {
  if (!identical(type, "uncategorized")) {
    link_field <- sprintf("links_%s", type)
  } else {
    link_field <- "links"
  }

  if (!link_field %in% names(hit)) {
    trail_s <- ifelse(!identical(type, "otherdocs"), "s", "")
    id <- attr(hit, 'id')
    rg_stop(c(
      "No {.field {type}}{trail_s} are available for record ID {.val {id}}.",
      "i" = "You can find out which file types are available using `gesis_file_types(\"{id}\")`."
    ))
  }
  hit[[link_field]]
}


filename_from_label <- function(file) {
  regex_match(file, "(^.+\\.[A-Za-z]+) ", i = 2)
}


#' @export
format.gesis_files <- function(x, ...) {
  cli::cli_format_method({
    cli::cli_text("{.cls {class(x)}}")

    for (i in seq_along(x)) {
      file <- x[[i]]
      label <- file$label_en %||% file$label
      if (!is.null(label)) {
        fname <- filename_from_label(label) %|||% label
        cli::cli_text("{.strong Label:} {fname}")
      }

      if (!is.null(file$format) && nzchar(file$format)) {
        cli::cli_text("{.strong Format:} {file$format}")
      }

      if (!is.null(file$filesize)) {
        size <- as.numeric(file$filesize) / 1048576
        cli::cli_text("{.strong File size:} {round(size, 2)} MB")
      }

      if (!is.null(file$secured)) {
        secured <- ifelse(isTRUE(as.logical(file$secured)), "yes", "no")
        cli::cli_text("{.strong Login required?} {secured}")
      }

      if (i != length(x)) {
        cli::cat_rule(width = 4)
      }
    }
  })
}


#' @export
print.gesis_files <- function(x, ...) {
  cat(format(x), sep = "\n")
  invisible(x)
}
