# GESIS files

Explore the files associated with a GESIS Search record. The output of
this function may guide you in selecting a file to download using
[`gesis_data`](https://jslth.github.io/rgesis/reference/gesis_data.md).

`gesis_file_types` gives an overview of the file categories, i.e.
datasets, questionnaires, codebooks or other documents, that are
available for a specific record.

## Usage

``` r
gesis_files(record, type = "dataset")

gesis_file_types(record)
```

## Arguments

- record:

  Object of class `gesis_record` as returned by
  [`gesis_search`](https://jslth.github.io/rgesis/reference/gesis_search.md)
  and `gesis_get` or dataset ID. If a dataset ID is passed, the function
  performs a call to
  [`gesis_get`](https://jslth.github.io/rgesis/reference/gesis_get.md).

- type:

  Type of data to download. A list of file types available for a given
  record can be retrieved using `gesis_file_types`. Common types
  include:

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

## Value

`gesis_files` returns a list of class `gesis_file` containing
information about the file name, format, size, download URL, and whether
the file needs a login to download.

`gesis_file_types` returns a character vector containing the file types
that are available. If `"none"`, files are available but not
categorized. If `NULL`, no files are available for download.

## Examples

``` r
# check what file types are available
gesis_file_types("ZA3753")
#> [1] "dataset"       "questionnaire" "codebook"      "otherdocs"    

# show all dataset files for ALLBUS 1998
gesis_files("ZA3753")
#> <gesis_files>
#> → File 1
#> Label: ZA3753.por
#> Format: application/x-spss-por
#> File size: 3.53 MB
#> Login required? yes
#> ────
#> → File 2
#> Label: ZA3753.sav
#> Format: application/x-spss-sav
#> File size: 2.55 MB
#> Login required? yes
#> ────
#> → File 3
#> Label: ZA3753_missing.sps
#> File size: 0.02 MB
#> Login required? yes
#> ────
#> → File 4
#> Label: ZA3753_variable-list.txt
#> File size: 0.02 MB
#> Login required? yes
#> ────
#> → File 5
#> Label: ZA3753_v1-0-0.dta.zip
#> File size: 0.64 MB
#> Login required? yes

# show all of its questionnaire files
gesis_files("ZA3753", type = "questionnaire")
#> <gesis_files>
#> → File 1
#> Label: ZA3000_fb.pdf
#> Format: pdf
#> Login required? no
#> ────
#> → File 2
#> Label: ZA3753_q.pdf
#> Format: pdf
#> Login required? no

# other record types can have files, too
type <- gesis_file_types("pretest-129")
gesis_files("pretest-129", type = "uncategorized")
#> <gesis_files>
#> → File 1
#> Label: Projektbericht
#> Login required? no
```
