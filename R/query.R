gesis_build_query <- function(query,
                              default_operator = "AND",
                              fields = field_weights(),
                              sort = "relevance",
                              type = NULL,
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
                              from = 1) {
  q <- list(from = from[[1]] %||% 0, sort = format_sort(sort))
  publication_year <- format_range(publication_year)
  collection_year <- format_range(collection_year)

  q |>
    drop_null() |>
    query_set_query(
      query = query,
      default_operator = default_operator,
      fields = fields
    ) |>
    query_set_filter(
      type = type,
      date.keyword = publication_year,
      countries_collection.keyword = countries,
      topic_en.keyword = topics,
      person.keyword = authors,
      data_source.keyword = sources,
      study_title_en.keyword = study_title,
      study_group_en.keyword = study_group,
      time_collection_years.keyword = collection_year,
      thematic_collection_en.keyword = thematic_collections,
      methodology_collection_ddi_en.keyword = method_data_collection,
      selection_method_ddi_en.keyword = method_sampling,
      time_method_en.keyword = method_time,
      analysis_unit_en.keyword = method_unit,
      kind_data_en.keyword = data_type,
      study_lang_en.keyword = interview_language,
      queryless = is.null(query)
    ) |>
    structure(class = "gesis_query")
}


format_sort <- function(sort) {
  switch(
    sort,
    relevance = NULL,
    newest_first = list(list(date_recency = list(order = "desc"))),
    oldest_first = list(list(date_recency = list(order = "asc"))),
    title_ascending = list(list(title.keyword = list(order = "asc"))),
    title_descending = list(list(title.keyword = list(order = "desc"))),
    variable_ascending = list(list(variable_name_sorting.keyword = list(order = "asc"))),
    variable_descending = list(list(variable_name_sorting.keyword = list(order = "desc")))
  )
}


format_range <- function(range) {
  if (!is.null(range)) {
    names(range) <- c("from", "to")
    range <- as.list(range)
  }
  range
}


query_set_query <- function(q, ...) {
  args <- list(...)

  if (is.null(args$query)) {
    # if no query is set, match all results and don't allow further query arguments
    q$query$bool$must$match_all <- drop_null(list(query = NULL))
    return(q)
  }

  for (n in names(args)) {
    q$query$function_score$query$bool$must[[1]]$query_string[[n]] <- args[[n]]
  }
  q
}


query_set_filter <- function(q, ..., queryless = FALSE) {
  args <- drop_null(list(...))
  if (!length(args)) return(q)
  filters <- lapply(names(args), function(n) {
    if (is.null(args[[n]])) return()
    filter <- args[[n]]
    box <- list()
    kw <- ifelse(length(filter) == 1, "term", "range")
    box[[kw]][[n]] <- args[[n]]
    box
  })

  if (queryless) {
    q$query$bool$filter <- filters
  } else {
    q$query$function_score$query$bool$filter <- filters
  }

  q
}


#' Construct field weights
#' @description
#' Construct a vector that can be used to weight metadata fields of search records.
#' To be used as input to the \code{fields} argument in
#' \code{\link{gesis_search}}.
#'
#' @param ... Key-value pairs where the key is the name of the field and the
#' value is the weight.
#' @param use_default Whether to use a sensible default when passing nothing
#' to \code{...}.
#' @returns A character vector of field weights.
#'
#' @export
#'
#' @examples
#' # use default weights
#' field_weights()
#'
#' # set a stronger weight on the abstract
#' field_weights(abstract = 5)
#'
#' # set no weights
#' field_weights(use_default = FALSE)
field_weights <- function(..., use_default = TRUE) {
  assert_dots_named(...)

  if (is.null(...names()) && use_default) {
    args <- list(
      title = 10,
      topic = 7,
      abstract = 3,
      source = 3,
      title_en = 10,
      topic_en = 7,
      abstract_en = 3,
      "id",
      title.partial = 0.4,
      topic.partial = 0.2,
      content.partial = 0.2,
      id.partial = 0.4,
      full_text = 0.1
    )
  } else {
    args <- list(...)
  }

  fields <- c(paste(names(args), args, sep = "^"))
  gsub("^\\^", "", fields)
}


#' @export
print.gesis_query <- function(x, pretty = TRUE, ...) {
  print(jsonlite::toJSON(x, force = TRUE, pretty = pretty, ...))
  invisible(x)
}
