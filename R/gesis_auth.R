#' Authenticate user
#' @description
#' Authenticate a GESIS user account using OpenID. This is necessary to
#' download datasets using \code{\link{gesis_data}}.
#'
#' @param email,password Email address and password linked to a GESIS user
#' account. These values should preferably be provided using
#' \code{options(gesis_email = ..., gesis_password = ...)} in \code{.Rprofile}
#' to make code files reproducible. If not specified and \code{prompt = TRUE},
#' asks for email and password interactively.
#' @param prompt If \code{TRUE} and \code{email} or \code{password} are
#' not specified, opens a console prompt to provide these arguments. If
#' \code{FALSE}, throws an error in this case. Defaults to \code{TRUE} if
#' run in an interactive session.
#'
#' @returns \code{NULL}, invisibly.
#'
#' @details
#' \code{gesis_auth()} performs a GESIS login once and, if successful, stores
#' the credentials used for the login in a \link[keyring:keyring_list]{keyring}
#' on the disk. For all subsequent authentications, the credentials are
#' retrieved from the keyring to authenticate automatically. To prevent the
#' authentication process to access the stored credentials every time an
#' OAuth request is sent, you can set \code{options(rgesis_cache_disk = TRUE)}
#' to allow the access token to be cached. Note that this comes at the cost
#' of storing access credentials on disk. See
#' \code{\link[httr2]{req_oauth_password}} for details.
#'
#' @export
#'
#' @examples
#' if (FALSE) {
#' # if email and password are provided in .Rprofile, gesis_auth() can be called without parameters
#' options(gesis_email = "name@test.org", gesis_password = "DONTLOOK")
#' gesis_auth()
#'
#' # email and password can also be provided manually -- not recommended
#' gesis_auth(email = "name@test.org", password = "DONTLOOK")
#' }
gesis_auth <- function(email = getOption("gesis_email"),
                       password = getOption("gesis_password"),
                       prompt = interactive()) {
  assert_keyring_support()
  assert_vector(email, "character", size = 1, null = TRUE)
  assert_vector(password, "character", size = 1, null = TRUE)
  assert_flag(prompt)

  if (is.null(email) && prompt) {
    cli::cli_inform(c("i" = "Email not set, needs manual input."))
    email <- readline("Please specify a user email: ")
  }

  if (is.null(password) && prompt) {
    cli::cli_inform(c("i" = "Password not set, needs manual input."))
    password <- readline("Please specify a password: ")
  }

  if (is.null(password) || is.null(email)) {
    rg_stop(c(
      "Both email and password are needed to authenticate.",
      "i" = "You can set them in your .Rprofile using `options(gesis_email = ..., gesis_password = ...)`."
    ))
  }

  httr2::oauth_flow_password(gesis_client(), username = email, password = password)
  keyring::key_set_with_value("rgesis", username = email, password = password)
  cli::cli_alert_success("Successfully performed GESIS login.")
  invisible(NULL)
}


gesis_get_auth <- function() {
  email <- keyring::key_list("rgesis")[["username"]] %empty% NULL
  password <- keyring::key_get("rgesis", username = email) %except% NULL

  if (is.null(email) || is.null(password)) {
    rg_stop(c(
      "Credentials could not be loaded.",
      "i" = "You can set them using {.fn gesis_auth}."
    ))
  }

  list(email = email, password = password)
}


gesis_client <- function() {
  httr2::oauth_client(
    id = "gesis-gws-client",
    token_url = "https://login.gesis.org/realms/gesis/protocol/openid-connect/token"
  )
}


req_add_auth <- function(req) {
  creds <- gesis_get_auth()
  if (!length(drop_null(creds))) {
    return(req)
  }
  httr2::req_oauth_password(
    req,
    client = gesis_client(),
    username = creds$email,
    password = creds$password,
    scope = "openid",
    cache_disk = getOption("rgesis_cache_disk", FALSE)
  )
}
