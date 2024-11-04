#' @section Global options:
#' A number of global options can be set that change the behavior of package
#' functions. These include:
#'
#' \describe{
#'  \item{\code{rgesis_cache_disk}}{If \code{TRUE}, stores OAuth access tokens
#'  in the \code{httr2} cache. This prevents repeated authentication using
#'  credentials but stores access credentials on the disk. Defaults to
#'  \code{FALSE}.}
#'  \item{\code{rgesis_debug}}{Whether to echo GET requests before they are
#'  sent. Defaults to FALSE.}
#'  \item{\code{rgesis_download_purpose}}{Download purpose that must be
#'  specified before downloading any kind of data from the GESIS catalogue.
#'  This option is a way to specify a download purpose globally to prevent
#'  having to pass it as an argument to each call of \code{\link{gesis_data}}.}
#' }
#'
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL
