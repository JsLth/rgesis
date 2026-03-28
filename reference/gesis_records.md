# Methods for `gesis_records` objects

Methods and functions to print, format and cast to objects of class
`gesis_records`.

## Usage

``` r
# S3 method for class 'gesis_record'
format(x, max_persons = 5, compact = FALSE, ...)

# S3 method for class 'gesis_record'
print(x, max_persons = 3, compact = FALSE, ...)

# S3 method for class 'gesis_records'
format(
  x,
  n = getOption("gesis_print_n", 3),
  max_persons = 3,
  compact = getOption("gesis_compact", FALSE),
  ...
)

# S3 method for class 'gesis_records'
print(
  x,
  n = getOption("gesis_print_n", 3),
  max_persons = 3,
  compact = getOption("gesis_compact", FALSE),
  ...
)

gesis_record(record, index = NULL, id = NULL, score = NULL, ...)

gesis_records(x, ...)
```

## Arguments

- x:

  An object of type `gesis_record` or `gesis_records`. For
  `gesis_records`, a list-like consisting of objects of class
  `gesis_record`.

- max_persons:

  Maximum number of authors to print. Defaults to 5.

- compact:

  If `TRUE`, prints records in compact format, showing only the dataset
  identifier and title. If `FALSE`, shows the full record preview. Can
  be controlled through the option `getOption("gesis_compact")`.
  Defaults to `FALSE`.

- ...:

  Arguments passed to the respective methods. Currently unused in
  `gesis_records`. Can be used to provide additional attributes to
  `gesis_record`.

- n:

  Maximum number of records to print. Defaults to 3.

- record:

  A named list as returned by functions such as
  [`gesis_get`](https://jslth.github.io/rgesis/reference/gesis_get.md).

- index:

  The search index of the GESIS Search. If `NULL`, will be inferred from
  `record`.

- id:

  The unique identifier of the search record. If `NULL`, will be
  inferred from `record`.

- score:

  Search score. If `NULL`, will be inferred from `record`.

## Value

`print` methods return `x` invisibly. `format` functions return a
character string. `gesis_records` returns an object of class
`gesis_records`. `gesis_record` returns an object of class
`gesis_record`.

## Examples

``` r
# wrap a list of records as gesis_records
records <- list(gesis_get("ZA7500"), gesis_get("ZA4789"))
records <- gesis_records(records)

print(records) # full view
#> A list of <gesis_records> with 2 records
#> <gesis_record>
#> Type: research_data
#> ID: ZA7500
#> Title: European Values Study 2017: Integrated Dataset (EVS 2017)
#> Date: 2022
#> Persons:
#> • Gedeshi, Ilir
#> • Pachulia, Merab
#> • Poghosyan, Gevorg
#> • ... and 34 more
#> 
#> <gesis_record>
#> Type: research_data
#> ID: ZA4789
#> Title: European Values Study 2008: Georgia (EVS 2008)
#> Date: 2010
#> Person:
#> • Pachulia, Merab
print(records, compact = TRUE) # compact view
#> A list of <gesis_records> with 2 records
#> - European Values Study 2017: Integrated Dataset (EVS 2017)
#>    [ZA7500]
#> - European Values Study 2008: Georgia (EVS 2008) [ZA4789]
```
