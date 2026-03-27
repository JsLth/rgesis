# Authenticate user

Authenticate a GESIS user account using OAuth 2.0. This is necessary to
download datasets using
[`gesis_data`](https://jslth.github.io/rgesis/reference/gesis_data.md).

## Usage

``` r
gesis_auth(email = NULL, password = NULL, prompt = interactive())

gesis_can_auth()

gesis_pop_auth()
```

## Arguments

- email, password:

  Email address and password linked to a GESIS user account. These only
  have to be provided once and will be retrieved using
  [`key_get`](https://keyring.r-lib.org/reference/key_get.html)
  afterwards. If not specified and `prompt = TRUE`, safely asks for
  email and password interactively.

- prompt:

  If `TRUE` and `email` or `password` are not specified, opens a console
  prompt to provide these arguments. If `FALSE`, throws an error in this
  case. Defaults to `TRUE` if run in an interactive session.

## Value

`gesis_auth` and `gesis_pop_auth` return `NULL`, invisibly.
`gesis_can_auth` always returns `TRUE` or `FALSE`.

## Details

`gesis_auth()` performs a GESIS login once and, if successful, stores
the credentials used for the login in the operating system's built-in
credentials manager using
[keyrings](https://keyring.r-lib.org/reference/has_keyring_support.html).
For all subsequent authentications, the credentials are retrieved from
the keyring to authenticate automatically. To prevent the authentication
process to access the stored credentials every time an OAuth request is
sent, you can set `options(rgesis_cache_disk = TRUE)` to allow the
access token to be cached. Note that this comes at the cost of storing
access credentials on disk. See
[`req_oauth_password`](https://httr2.r-lib.org/reference/req_oauth_password.html)
for details.

To check if the package can successfully authenticate without passing
new credentials, you can run `gesis_can_auth()`. Note that this function
catches all types of errors that occur when trying to authenticate. It
does not make assumptions about the reason why an error occured. In
other words, a failing auth check is not a guarantee that an
authentication is invalid. This function can be handy to check if
datasets can be downloaded in automated workflows without throwing an
error. For example:

    if (gesis_can_auth()) {
      gesis_data(...)
    }

To remove the credentials from the operating system's credentials
manager, use `gesis_pop_auth()`.

## Note

Be advised to avoid entering your password in plain text. Instead, use
the masked password prompt that shows when not providing a value to the
`password` argument or store the credentials manually, e.g. using
[`key_set`](https://keyring.r-lib.org/reference/key_get.html).

## Examples

``` r
if (FALSE) { # \dontrun{
# if email and password are not stored yet, gesis_auth() registers them
# in a keyring and checks if they work
gesis_auth(email = "name@test.org", password = "DONTLOOK")

# if credentials are already stored in a keyring, gesis_auth() simply
# checks if the login works
gesis_auth()
} # }
```
