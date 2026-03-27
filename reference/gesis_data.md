# Download survey data

Downloads survey data from GESIS given a record or a dataset ID. To
download data, the session must be authenticated using
[`gesis_auth`](https://jslth.github.io/rgesis/reference/gesis_auth.md).

By downloading data from the GESIS data archive, you agree to its [terms
of
use](https://www.gesis.org/fileadmin/upload/dienstleistung/daten/umfragedaten/_bgordnung_bestellen/2023-06-30_Usage_regulations.pdf).
This function is intended to be used for singular, programmatic access
to survey datasets. Please refrain from using it for large-scale batch
downloads.

## Usage

``` r
gesis_data(
  record,
  download_purpose = NULL,
  path = tempdir(),
  type = "data",
  select = NULL,
  prompt = interactive(),
  overwrite = FALSE
)
```

## Arguments

- record:

  Object of class `gesis_record` as returned by
  [`gesis_search`](https://jslth.github.io/rgesis/reference/gesis_search.md)
  and `gesis_get` or dataset ID. If a dataset ID is passed, the function
  performs a call to
  [`gesis_get`](https://jslth.github.io/rgesis/reference/gesis_get.md).

- download_purpose:

  Purpose for the use of the research data. You are required to use the
  downloaded data solely for the specified purpose (see also the [terms
  of
  use](https://www.gesis.org/fileadmin/upload/dienstleistung/daten/umfragedaten/_bgordnung_bestellen/2023-06-30_Usage_regulations.pdf)).
  The following values are supported:

  - `final_thesis`: for final thesis of the study programme (e.g.
    Bachelor/Master thesis)

  - `commercial_research`: for research with a commercial mission

  - `non_scientific`: for non-scientific purposes

  - `further_education`: for further education and qualification

  - `scientific_research`: for scientific research (incl. doctorate)

  - `studies`: in the course of my studies

  - `lecturer`: in a course as a lecturer

- path:

  Path where the downloaded file should be stored. Can be path to a
  directory or a file. If a directory path, it is attempted to infer the
  file name from the file to be downloaded. If this is not possible, the
  file is stored in a file called `gesis` with no file extension. If a
  file path is passed, the file is directly downloaded to this path.
  Defaults to a temporary directory path.

- type:

  Type of data to download. A list of file types available for a given
  record can be retrieved using
  [`gesis_file_types`](https://jslth.github.io/rgesis/reference/gesis_files.md).
  Common types include:

  - `data`: Research or survey dataset, usually in a Stata or SPSS data
    format.

  - `questionnaire`: Survey questionnaire, usually in PDF format

  - `codebook`: Survey codebook, usually in PDF format

  - `report`: Method, project or technical reports, usually in PDF
    format.

  - `syntax`: Code files, e.g. for replication or data cleaning

  - `other`: Other files like READMEs, method reports, or variable
    lists, usually in PDF format.

  - `uncategorized`: Other files that are not categorized, usually used
    for external links to full texts (DOI, URN)

  Defaults to `"data"` because downloading PDF or HTML files rarely
  makes sense in R. Note that `"data"`, `"report"`, and `"other"` are
  keywords that cover all types of datasets, written reports, and other
  documents respectively.

- select:

  Character vector to select a data file in case multiple files are
  available for the selected data type. The character string is matched
  against the file label using regular expressions. This argument can
  also be used to match explicitly for file extensions, e.g. `"\\.sav"`
  or `"\\.dat"`. Can also be of length \> 1 in which case the regular
  expressions are matched in the order of their index positions. A list
  of file labels for a given record can be retrieved using
  [`gesis_files`](https://jslth.github.io/rgesis/reference/gesis_files.md).
  If `NULL`, multiple files are detected, and the session is
  interactive, prompts the user to select a file. Defaults to `NULL`.

- prompt:

  If `TRUE`, allows the function to open an interactive prompt in case
  multiple files are found and `select` is either `NULL` or fails to
  select a file unambiguously. If `FALSE`, throws an error in such a
  case. Defaults to `TRUE` if run in an interactive session.

- overwrite:

  If `TRUE`, overwrites any existing file with the downloaded file. If
  `FALSE`, returns the file path without downloading if the file already
  exists. Defaults to `FALSE`.

## Value

The path to the downloaded file. Depending on the selected file, there
are different ways to read the file contents. Traditionally, data files
are offered in Stata and SPSS file formats and can be read using the
[haven](https://haven.tidyverse.org/) package.

## Details

Access and refresh tokens are automatically attached to the requests
sent if possible. This is done only for URLs pointing to the domain
gesis.org to avoid sending authentication information to other domains.

## Examples

``` r
if (FALSE) { # getFromNamespace("gesis_can_auth", "rgesis")()
# retrieve a search record to pass on to gesis_data()
record <- gesis_search(
  "allbus",
  publication_year = c(2019, 2020),
  type = "research_data"
)

# in interactive mode, the function can be run without arguments
path <- gesis_data(record[[1]])

# in other cases, certain arguments should be provided
path <- gesis_data(record[[1]], download_purpose = "non_scientific", select = "\\.sav")

# you can also simply pass a dataset ID
path <- gesis_data("ZA3753", select = "\\.por")

# data files must be read using other tools and packages, e.g. haven
haven::read_por(path)

# ... or pdftools
path <- gesis_data("ZA3753", select = "fb\\.pdf", type = "questionnaire")
pdftools::pdf_text(path)

# In some cases, a single selection regex might be difficult to work
# with, e.g., if multiple files with the same format exist.
# In this case, you may pass multiple regular expressions which are
# evaluated back by back
gesis_data(
  "ZA7716",
  select = c("\\.sav", "main"),
  download_purpose = "non_scientific"
)
}
```
