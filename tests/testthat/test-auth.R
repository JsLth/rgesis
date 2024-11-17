skip_if_not(keyring::has_keyring_support())

local_mocked_bindings(rgesis_keyring = function() "rgesis_test")

if (nrow(keyring::key_list("rgesis_test"))) {
  keyring::key_delete("rgesis_test", "testcreds")
}

test_that("auth fails early", {
  expect_error(gesis_get_auth(), "could not be loaded")
})

test_that("requires credentials", {
  expect_error(gesis_auth(prompt = FALSE), "email and password")
})

test_that("gesis_can_auth() does not error", {
  expect_false(gesis_can_auth())
})

local_mocked_bindings(
  oauth_flow_password = function(...) NULL,
  .package = "httr2"
)

local_mocked_bindings(
  readline = function(...) "testcreds",
  .package = "base"
)

test_that("can set an auth", {
  expect_message(gesis_auth(prompt = TRUE), "GESIS login")
  creds <- gesis_get_auth()
  expect_equal(creds$email, "testcreds")
  expect_equal(creds$password, "testcreds")
})

skip_if_offline("gesis.org")
skip_on_cran()

record <- gesis_get("ZA5272")

local_mocked_bindings(
  .package = "utils",
  menu = function(...) 1
)

test_that("gesis_data() fails early", {
  expect_error(gesis_data(record, prompt = FALSE), "Multiple data files")
  expect_error(gesis_data(record, select = "badselect", prompt = TRUE))
})

local_mocked_bindings(gesis_download = function(path, ...) list(body = path))

test_that("can select data", {
  expect_true(endsWith(suppressWarnings(gesis_data(record, prompt = TRUE)), ".dta.zip"))
  expect_true(endsWith(suppressWarnings(gesis_data(record, select = "\\.sav", prompt = TRUE)), ".sav.zip"))
})