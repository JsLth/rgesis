#' Get a GESIS record
#' @description
#' Performs a simple lookup of a specific GESIS record ID and retrieves its
#' metadata record from the data archive.
#'
#' @param id Dataset ID of the record.
#'
#' @returns An object of class \code{gesis_record}.
#'
#' @export
#'
#' @examples
#' \donttest{# retrieve metadata on the ALLBUS microdata record
#' gesis_get("ZA5262")}
gesis_get <- function(id) {
  assert_vector(id, "character", size = 1)

  hit <- gesis_search(sprintf("_id:%s", id))

  if (!length(hit)) {
    rg_stop(c(
      "{.val {hit_string}} is not a valid dataset ID.",
      "i" = "Did you mean to `gesis_search(\"{id}\")`?"
    ))
  }

  hit[[1]]
}
