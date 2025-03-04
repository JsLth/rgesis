#' Get a GESIS record
#' @description
#' Performs a simple lookup of one or multiple specific GESIS record ID and
#' retrieves their metadata record from the data archive.
#'
#' @param ids Dataset IDs of the records.
#'
#' @returns An object of class \code{gesis_record}.
#'
#' @export
#'
#' @examples
#' \donttest{# retrieve metadata on the ALLBUS microdata record
#' gesis_get("ZA5262")
#'
#' # retrieve ALLBUS 2014, 2016, and 2018
#' gesis_get(c("ZA5240", "ZA5250", "ZA5270"))}
gesis_get <- function(ids) {
  assert_vector(ids, "character")
  records <- gesis_records(lapply(ids, gesis_get_single))
  if (length(records) == 1) {
    records <- records[[1]]
  }
  records
}


gesis_get_single <- function(id) {
  hit <- gesis_search(sprintf("_id:%s", id))

  if (!length(hit)) {
    rg_stop(c(
      "{.val {id}} is not a valid dataset ID.",
      "i" = "Did you mean to `gesis_search(\"{id}\")`?"
    ))
  }

  hit[[1]]
}
