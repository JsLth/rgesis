skip_on_cran()
skip_if_offline("gesis.org")

records <- gesis_search()

test_that("queryless search works", {
  expect_length(records, 10)
})

test_that("field weights work", {
  expect_error(field_weights("test"), class = "assert_dots_named")
  expect_vector(field_weights(use_default = FALSE), ptype = character(), size = 0)
  expect_vector(field_weights(title = 1), ptype = character(), size = 1)
})

test_that("range arguments work", {
  expect_failure(expect_identical(
    gesis_search(publication_year = c(2010, 2014)),
    records
  ))
})

test_that("sorting works", {
  expect_failure(expect_identical(
    gesis_search(sort = "title_asc"),
    records
  ))
})

test_that("results can be tidied", {
  expect_equal(nrow(gesis_search(tidy = TRUE)), 10)
})

test_that("pages can be flipped", {
  expect_length(gesis_search(pages = 1:2), 20)
  expect_gt(length(
    gesis_search("bruno latour", pages = NULL, fields = field_weights(person = 10))
  ), 10)
})

test_that("print method prints", {
  expect_output(print(gesis_search()))
})

test_that("file types can be retrieved", {
  expect_null(gesis_file_types("gesis-bib-60925"))
  expect_equal(gesis_file_types("gesis-ssoar-54633"), "uncategorized")
  expect_gt(length(gesis_file_types("ZA5272")), 1)
})

test_that("file metadata can be retrieved", {
  files <- gesis_files("ZA5272", "dataset")
  expect_s3_class(files, "gesis_files")
  expect_output(print(files))
})

test_that("gesis_get is vectorized and gesis records can be casted", {
  expect_identical(
    gesis_get(c("ZA7500", "ZA4789")),
    as_gesis_records(list(gesis_get("ZA7500"), gesis_get("ZA4789")))
  )
})
