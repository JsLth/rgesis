skip_if_not(keyring::has_keyring_support())

local_mocked_bindings(rgesis_keyring = function() "rgesis_test")

if (!nrow(keyring::keyring_list())) {
  keyring::keyring_create("system", password = "")
  on.exit(keyring::keyring_delete("system"))
}

if (nrow(keyring::key_list("rgesis_test"))) {
  keyring::key_delete("rgesis_test", "testcreds")
}

test_that("auth fails early", {
  expect_error(gesis_get_auth(), class = "assert_has_key")
})

test_that("requires credentials", {
  expect_error(gesis_auth(prompt = FALSE), class = "incomplete_creds")
})

test_that("gesis_can_auth() does not error", {
  expect_false(gesis_can_auth())
})

local_mocked_bindings(
  oauth_flow_password = function(...) NULL,
  .package = "httr2"
)

local_mocked_bindings(ask = function(...) "testcreds")

test_that("can set an auth", {
  expect_message(gesis_auth(prompt = TRUE), "GESIS login")
  creds <- gesis_get_auth()
  expect_equal(creds$email, "testcreds")
  expect_equal(creds$password, "testcreds")
})

on.exit(gesis_pop_auth())
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
