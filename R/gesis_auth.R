#' Authenticate user
#' @description
#' Authenticate a GESIS user account using OAuth 2.0. This is necessary to
#' download datasets using \code{\link{gesis_data}}.
#'
#' @param email,password Email address and password linked to a GESIS user
#' account. These only have to be provided once and will be retrieved using
#' \code{\link[keyring]{key_get}} afterwards. If not specified and
#' \code{prompt = TRUE}, safely asks for email and password interactively.
#' @param prompt If \code{TRUE} and \code{email} or \code{password} are
#' not specified, opens a console prompt to provide these arguments. If
#' \code{FALSE}, throws an error in this case. Defaults to \code{TRUE} if
#' run in an interactive session.
#'
#' @returns \code{gesis_auth} and \code{gesis_pop_auth} return \code{NULL},
#' invisibly. \code{gesis_can_auth} always returns \code{TRUE} or \code{FALSE}.
#'
#' @details
#' \code{gesis_auth()} performs a GESIS login once and, if successful, stores
#' the credentials used for the login in the operating system's built-in
#' credentials manager using \link[keyring:keyring_list]{keyrings}. For all
#' subsequent authentications, the credentials are retrieved from the keyring
#' to authenticate automatically. To prevent the authentication process to
#' access the stored credentials every time an OAuth request is sent, you can
#' set \code{options(rgesis_cache_disk = TRUE)} to allow the access token to
#' be cached. Note that this comes at the cost of storing access credentials on
#' disk. See \code{\link[httr2]{req_oauth_password}} for details.
#'
#' To check if the package can successfully authenticate without passing
#' new credentials, you can run \code{gesis_can_auth()}. Note that this
#' function catches all types of errors that occur when trying to
#' authenticate. It does not make assumptions about the reason why an error
#' occured. In other words, a failing auth check is not a guarantee that an
#' authentication is invalid. This function can be handy to check if datasets
#' can be downloaded in automated workflows without throwing an error. For
#' example:
#'
#' \preformatted{if (gesis_can_auth()) {
#'   gesis_data(...)
#' }}
#'
#' To remove the credentials from the operating system's credentials manager,
#' use \code{gesis_pop_auth()}.
#'
#' @note
#' Be advised to avoid entering your password in plain text. Instead, use
#' the masked password prompt that shows when not providing a value to the
#' \code{password} argument or store the credentials manually, e.g. using
#' \code{\link[keyring]{key_set}}.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # if email and password are not stored yet, gesis_auth() registers them
#' # in a keyring and checks if they work
#' gesis_auth(email = "name@test.org", password = "DONTLOOK")
#'
#' # if credentials are already stored in a keyring, gesis_auth() simply
#' # checks if the login works
#' gesis_auth()
#' }
gesis_auth <- function(email = NULL,
                       password = NULL,
                       prompt = interactive()) {
  assert_keyring_support()
  assert_vector(email, "character", size = 1, null = TRUE)
  assert_vector(password, "character", size = 1, null = TRUE)
  assert_flag(prompt)

  if (is.null(email) && is.null(password) && has_key()) {
    assert_login()
    return(invisible())
  }

  email <- email %||% gesis_get_email()
  password <- password %||% gesis_get_password()

  if (is.null(email) && prompt) {
    cli::cli_inform(c("i" = "Email not set, needs manual input."))
    email <- ask_cred("username")
  }

  if (is.null(password) && prompt) {
    cli::cli_inform(c("i" = "Password not set, needs manual input."))
    password <- ask_cred("password")
  }

  if (is.null(password) || is.null(email)) {
    rg_stop(
      "Both email and password are needed to authenticate.",
      class = "incomplete_creds"
    )
  }

  assert_login(email = email, password = password)
  gesis_set_auth(email = email, password = password)
  invisible(NULL)
}


#' @rdname gesis_auth
#' @export
gesis_can_auth <- function() {
  assert_login(quiet = TRUE) %except% FALSE
}


#' @rdname gesis_auth
#' @export
gesis_pop_auth <- function() {
  assert_has_key()
  keyring::key_delete(rgesis_keyring(), gesis_get_email())
  invisible(NULL)
}


ask_cred <- function(type = "password") {
  prompt <- switch(
    type,
    password = "Please enter your password",
    username = "Please enter your username"
  )
  ask(prompt) %||% rg_stop("Prompt interrupted.", call = NULL)
}


has_key <- function(email) {
  keyring <- rgesis_keyring()
  keys <- keyring::key_list(keyring)
  if (nrow(keys) > 1) {
    rg_stop(c(
      "Multiple credentials found in keyring {.val {keyring}}.",
      "i" = "You can manually fix this using `keyring::key_delete()`."
    ), class = "multiple_keys")
  }
  nrow(keys) == 1
}


assert_login <- function(email = NULL, password = NULL, quiet = FALSE) {
  if (is.null(email) && is.null(password)) {
    creds <- gesis_get_auth()
    email <- creds$email
    password <- creds$password
  }

  httr2::oauth_flow_password(
    gesis_client(),
    username = email,
    password = password
  )

  if (!quiet) {
    cli::cli_alert_success("Successfully performed GESIS login.")
  }

  TRUE
}


assert_has_key <- function() {
  if (!has_key()) {
    rg_stop(c(
      "No credentials stored in keyring {.val {rgesis_keyring()}}.",
      "i" = "You can set them using {.fn gesis_auth}."
    ), class = "assert_has_key")
  }
}


gesis_set_auth <- function(email, password) {
  keyring::key_set_with_value(
    rgesis_keyring(),
    username = email,
    password = password
  )
}


# try to get email, return NULL if not found
gesis_get_email <- function() {
  keyring::key_list(rgesis_keyring())[["username"]] %empty% NULL
}


# try to get password, return NULL if not found
gesis_get_password <- function() {
  email <- gesis_get_email()
  keyring::key_get(rgesis_keyring(), username = email) %except% NULL
}


# get email and password, throw error if not found
gesis_get_auth <- function() {
  assert_has_key()
  keys <- keyring::key_list(rgesis_keyring())
  email <- keys[["username"]]
  password <- keyring::key_get(rgesis_keyring(), username = email)
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
  httr2::req_oauth_password(
    req,
    client = gesis_client(),
    username = creds$email,
    password = creds$password,
    scope = "openid",
    cache_disk = getOption("rgesis_cache_disk", FALSE)
  )
}


rgesis_keyring <- function() "rgesis"
