request_searchengine <- function(source, from) {
  source_json <- jsonlite::toJSON(source, auto_unbox = TRUE, force = TRUE)
  req <- httr2::request("https://search.gesis.org/searchengine")
  req <- httr2::req_url_query(
    req,
    source = source_json,
    source_content_type = "application/json"
  )
  debug_req(req)

  if (is.null(from) || length(from) > 1) {
    httr2::req_perform_iterative(
      req,
      next_req = iterate_with_source(from),
      max_reqs = ifelse(is.null(from), Inf, length(from))
    ) |>
      httr2::resps_successes() |>
      httr2::resps_data(\(resp) httr2::resp_body_json(resp)$hits$hits)
  } else {
    resp <- httr2::req_perform(req)
    httr2::resp_body_json(resp)$hits$hits
  }
}


iterate_with_source <- function(from) {
  resp_complete <- function(resp) {
    hits <- httr2::resp_body_json(resp)$hits$hits
    length(hits) == 0
  }

  i <- 1
  function(resp, req) {
    # if maximum number of pages is reached, return
    if (!is.null(from) && length(from) == i) {
      return()
    }

    if (!resp_complete(resp)) {
      i <<- i + 1
      source <- httr2::url_parse(req$url)$query$source
      source <- jsonlite::fromJSON(source, simplifyVector = FALSE)

      if (is.null(from)) {
        # if number of pages is infinite, interpret iterator as page
        # this leads to infinite pagination
        source$from <- page_to_from(i)
      } else {
        # otherwise, take the page start from the from vector
        source$from <- from[[i]]
      }

      source <- jsonlite::toJSON(source, auto_unbox = TRUE)
      req <- httr2::req_url_query(req, source = source)
      debug_req(req)
      req
    }
  }
}


debug_req <- function(req) {
  if (getOption("rgesis_debug", FALSE)) {
    cli::cli_inform("GET {utils::URLdecode(req$url)}")
  }
}
