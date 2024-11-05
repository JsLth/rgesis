#' GESIS Search
#' @description
#' Query the GESIS search engine to retrieve metadata on research data,
#' variables, tools, publications, libraries, and websites.
#'
#' @param query The search term to query. Terms can be seperated by operators
#' OR / AND. If no operator is specified, defaults to the operator specified
#' in \code{default_operator}. If \code{NULL}, searches for all records.
#' Queryless searches can still be filtered using the parameters below.
#' @param type Type of search results to retrieve. Can be one of
#' \code{"research_data"}, \code{"variables"}, \code{"instruments_tools"},
#' \code{"publication"}, \code{"gesis_bib"}, or \code{"gesis_web"} or
#' \code{"gesis_person"}. If \code{NULL}, includes all result types. Defaults to
#' \code{NULL}.
#' @param default_operator Character specifying the default operator to use
#' as seperator of search terms. Can be \code{"AND"} or \code{"OR"}. Defaults
#' to \code{"AND"}. Ignored if \code{query} is \code{NULL}.
#' @param fields Character vector of field weights as returned by
#' \code{\link{field_weights}}. Used to specify how much weight is given to
#' query matches in certain metadata fields. The higher the weight, the more
#' a field influences the match probability. Defaults to the default values
#' specified by \code{\link{field_weights}}. Ignored if \code{query} is
#' \code{NULL}.
#' @param sort Attribute to sort by. Must be one of \code{"relevance"},
#' \code{"newest_first"}, \code{"oldest_first"}, \code{"title_ascending"},
#' \code{"title_descending"}, \code{"variable_ascending"}, or
#' \code{"variable_descending"}. Defaults to \code{"relevance"}.
#' @param publication_year Numeric or character vector of length 2 specifying
#' the time range in which a record was published. The first value is the start
#' year and the second value is the end year. If \code{NULL}, returns records
#' from all years. Defaults to \code{NULL}.
#' @param countries Character vector specifying the country in which the record
#' was published. If \code{NULL}, returns records from all countries. Defaults
#' to \code{NULL}.
#' @param topics Character vector specifying the topics to filter by. Example
#' values include "Political behavior and attitudes" or "Migration". See
#' \url{https://search.gesis.org/} for a full list of possible topics.
#' @param authors Character vector specifying the authors to filter by.
#' @param sources Character vector specifying the source of the record.
#' @param study_title Character vector specifying the study title. Only
#' sensible for research data or variables.
#' @param study_group Character vector specifying the study group. Only
#' sensible for research data or variables.
#' @param collection_year Numeric or character vector of length 2 specifying
#' the time range in which a dataset was collected. The first value is the
#' start year and the second value is the end year. If \code{NULL}, returns
#' records from all years. Defaults to \code{NULL}. Only sensible for research
#' data or variables.
#' @param thematic_collections Character vector specifying the thematic
#' collection a dataset or variable belongs to. Example values include
#' "COVID-19" or "Environment and climate". See \url{https://search.gesis.org/}
#' for a full list of possible topics.
#' @param method_data_collection,method_sampling,method_time,method_unit Arguments
#' to filter by the methodology used in a study. It is possible to filter by
#' the mode of data collection (\code{method_data_collection}), sampling
#' procedure (\code{method_sampling}), temporal research design
#' (\code{method_unit}) and analysis unit (\code{method_unit}). Only sensible
#' for research data and variables.
#' @param data_type Character vector specifying the data type of a dataset or
#' variable. Example values include \code{"numeric"}, \code{"geospatial"},
#' and \code{"text"}. Only sensible for research data and variables.
#' @param interview_language Character vector specifying the interview
#' language of a variable. Usually only \code{"german"} and \code{"english"}
#' are available. Only sensible for variables.
#' @param pages Numeric vector specifying the page numbers of the search results.
#' By default, only the first page is returned. If \code{NULL}, iterates through
#' all pages.
#' @param tidy If \code{TRUE}, returns the records in a rectangular shape that
#' can be wrangled more easily. In this form, some more complex metadata fields
#' that cannot be converted to a rectangular shapre are discarded. If
#' \code{FALSE}, returns the records as a list-like \code{gesis_hits} object.
#' This object is more comprehensive, but harder to work with. Defaults to
#' \code{FALSE}.
#'
#' @returns If \code{tidy = FALSE}, returns an object of class
#' \code{gesis_hits} consisting of multiple objects of class \code{gesis_hit}.
#' Each \code{gesis_hit} contains attributes \code{index}, \code{id}, and
#' \code{score} specifying the index, the record ID, and the match score.
#'
#' If \code{tidy = TRUE}, returns a dataframe or tibble where each
#' row is a record and each column is a metadata field.
#'
#' In any case, the query used to retrieve the data is stored in the attribute
#' \code{query}.
#'
#' @export
#'
#' @examples
#' \donttest{# Make a queryless search across the entire database and return
#' # the first 10 results
#' gesis_search()
#'
#' # Queries can be narrowed down by providing a query string
#' hit <- gesis_search("climate change")
#'
#' # gesis_search() searches for all types of records by default. If you only
#' # want to search for, say, datasets, you can set the `type` argument.
#' gesis_search(type = "research_data")
#'
#' # By default, only 10 results (1 page) are returned. You can specify
#' # which pages should queried or if all should be returned
#' gesis_search("climate change", pages = 2:3) # pages 2 and 3
#' if (FALSE) gesis_search("climate change", pages = NULL) # all pages
#'
#' # By default, results are wrapped in a complex list structure. This is
#' # good for representing detailed information, but not for analyzing data.
#' # Results can be tidied up to a dataframe using either `as_tibble()`
#' # or by setting the `tidy` argument to TRUE
#' tibble::as_tibble(hit)
#' gesis_search("climate change", tidy = TRUE)
#'
#' # Using the fields argument you can control how different text fields
#' # are weighted in matching the query string. Here we search for
#' # "climate change" only in full texts, not in other fields
#' gesis_search("climate change", fields = field_weights(full_text = 10))
#'
#' # Search strings are separated by an AND operator by default
#' # this default can be overwritten by setting default_operator = "OR"
#' # or by manually separating the query string
#' weight <- field_weights(title = 100)
#' and <- gesis_search(
#'   "climate change",
#'   sort = "title_ascending",
#'   fields = weight
#' )
#' or1 <- gesis_search(
#'   "climate OR change",
#'   sort = "title_ascending",
#'   fields = weight
#' )
#' or2 <- gesis_search(
#'   "climate change",
#'   sort = "title_ascending",
#'   default_operator = "OR",
#'   fields = weight
#' )
#' attr(and, "query") <- NULL
#' attr(or1, "query") <- NULL
#' attr(or2, "query") <- NULL
#' identical(and, or1)
#' identical(or1, or2)
#'
#' # Similarly, you can construct complex query terms using operators
#' gesis_search("(climate or environmental) AND (change OR crisis OR action)")
#'
#' # Another way to narrow down the search is to set filters. GESIS Search
#' # offers a number of filters, including topic, publication year or
#' # methodology. Sensible values can be checked on https://search.gesis.org/.
#' gesis_search(topics = "climate change", type = "publication")}
gesis_search <- function(query = NULL,
                         type = NULL,
                         default_operator = "AND",
                         fields = field_weights(),
                         sort = "relevance",
                         publication_year = NULL,
                         countries = NULL,
                         topics = NULL,
                         authors = NULL,
                         sources = NULL,
                         study_title = NULL,
                         study_group = NULL,
                         collection_year = NULL,
                         thematic_collections = NULL,
                         method_data_collection = NULL,
                         method_sampling = NULL,
                         method_time = NULL,
                         method_unit = NULL,
                         data_type = NULL,
                         interview_language = NULL,
                         pages = 1,
                         tidy = FALSE) {
  sort <- match_arg(sort, choices = c(
    "relevance", "newest_first", "oldest_first", "title_ascending",
    "title_descending", "variable_ascending", "variable_descending"
  ))
  type <- match_arg(type, null = TRUE, choices = c(
    "research_data", "variables", "instruments_tools", "publication",
    "gesis_bib", "gesis_web", "gesis_person"
  ))
  default_operator <- match_arg(default_operator, choices = c("AND", "OR"))
  assert_vector(query, "character", size = 1, null = TRUE)
  assert_vector(fields, "character")
  assert_vector(publication_year, size = 2, null = TRUE)
  assert_vector(countries, "character", size = 1, null = TRUE)
  assert_vector(topics, "character", null = TRUE)
  assert_vector(authors, "character", null = TRUE)
  assert_vector(sources, "character", null = TRUE)
  assert_vector(study_title, "character", null = TRUE)
  assert_vector(study_group, "character", null = TRUE)
  assert_vector(collection_year, size = 2, null = TRUE)
  assert_vector(thematic_collections, "character", null = TRUE)
  assert_vector(method_data_collection, "character", null = TRUE)
  assert_vector(method_sampling, "character", null = TRUE)
  assert_vector(method_time, "character", null = TRUE)
  assert_vector(method_unit, "character", null = TRUE)
  assert_vector(data_type, "character", null = TRUE)
  assert_vector(interview_language, "character", null = TRUE)
  assert_flag(tidy)

  if (!is.null(pages)) {
    from <- (pages - 1) * 10
  } else {
    from <- pages
  }

  source <- gesis_build_query(
    query = query,
    default_operator = default_operator,
    fields = fields,
    sort = sort,
    type = type,
    publication_year = publication_year,
    countries = countries,
    topics = topics,
    authors = authors,
    sources = sources,
    study_title = study_title,
    study_group = study_group,
    collection_year = collection_year,
    thematic_collections = thematic_collections,
    method_data_collection = method_data_collection,
    method_sampling = method_sampling,
    method_time = method_time,
    method_unit = method_unit,
    data_type = data_type,
    interview_language = interview_language,
    from = from
  )

  hits <- request_searchengine(source, from = from)

  hits <- lapply(hits, function(x) {
    structure(
      x[["_source"]],
      index = x[["_index"]],
      id = x[["_id"]],
      score = x[["_score"]],
      class = "gesis_hit"
    )
  })
  class(hits) <- "gesis_hits"

  if (tidy) {
    hits <- as_data_frame(hits)
  }

  attr(hits, "query") <- source
  hits
}


page_to_from <- function(pages) {
  (pages - 1) * 10
}


#' @export
#' @rdname gesis_search
#' @param x Object of class \code{gesis_hits}
#' @param ... Arguments passed on to the respective S3 methods.
as.data.frame.gesis_hits <- function(x, ...) {
  x <- lapply(x, function(rec) {
    id <- attr(rec, "id")
    lens <- lengths(rec)

    # drop all null or empty fields to prevent dataframe from going corrupt
    rec <- rec[lengths(rec) > 0]

    # drop all deeply nested lists
    nst <- vapply(rec, \(f) all(lengths(f) > 1), FUN.VALUE = logical(1))
    rec <- rec[!nst]

    rec <- lapply(rec, function(f) {
      if (inherits(f, "list")) {
        # flatten vectors that do not need to be in a list
        f <- unlist(f)

        # vectors must not be length > 1 to be put in a 1-row dataframe
        # this is the basis to create a dataframe with nesting
        if (length(f) > 1) {
          f <- list(f)
        }
      }
      f
    })

    # in some cases, the id is not part of the record. if so, add it
    if (!"id" %in% names(rec)) {
      rec <- c(id = id, rec)
    }

    # squeeze list objects into a nested dataframe structure that also works
    # in base R
    as_nested_dataframe(drop_null(rec))
  })

  x <- rbind_list(x, fill_in = NA_character_)
  first_nms <- c("id", "title", "type", "date")
  new_nms <- c(first_nms, setdiff(names(x), first_nms))
  new_nms <- union(new_nms, names(x))
  x[new_nms]
}


#' @export
format.gesis_hit <- function(x, max_persons = 5, ...) {
  cli::cli_format_method({
    cli::cli_text("{.cls {class(x)}}")

    if (!is.null(x$type)) {
      cli::cli_text("{.strong Type:} {x$type}")
    }

    if (!is.null(attr(x, "id"))) {
      cli::cli_text("{.strong ID:} {attr(x, \"id\")}")
    }

    if (!is.null(x$title)) {
      cli::cli_text("{.strong Title:} {x$title}")
    }

    if (!is.null(x$date)) {
      cli::cli_text("{.strong Date:} {x$date}")
    }

    if (!is.null(x$person)) {
      persons <- x$person
      n_persons <- length(persons)
      if (n_persons > max_persons) {
        persons <- persons[1:max_persons]
        persons <- c(persons, "... and {n_persons - 5} more")
      }
      names(persons) <- rep("*", length(persons))
      cli::cli_text("{cli::qty(persons)} {.strong Person{?s}:}")
      cli::cli_bullets(persons)
    }
  })
}


#' @export
print.gesis_hit <- function(x, max_persons = 5, ...) {
  cat(format(x, max_persons = max_persons, ...), sep = "\n")
  invisible(x)
}


#' @export
format.gesis_hits <- function(x, n = 3, max_persons = 5, ...) {
  cli::cli_format_method({
    cli::cli_text("A list of {.cls gesis_hits} with {length(x)} hits")

    if (length(x)) {
      for (i in seq(1, min(length(x), n))) {
        cli::cat_line()
        print(x[[i]], max_persons = max_persons, ...)
      }

      if (length(x) > 5) {
        cli::cli_text(cli::col_grey("# {cli::symbol$info} {length(x) - {n}} more hits"))
        cli::cli_text(cli::col_grey("# {cli::symbol$info} Use `print(n = ...)` to see more hits"))
      }
    }
  })
}


#' @export
print.gesis_hits <- function(x, n = 5, max_persons = 5, ...) {
  cat(format(x, n = n, max_persons = max_persons, ...), sep = "\n")
  invisible(x)
}
