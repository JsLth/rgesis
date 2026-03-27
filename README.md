
<!-- README.md is generated from README.Rmd. Please edit that file -->

# rgesis

<!-- badges: start -->

[![R-CMD-check](https://github.com/jslth/rgesis/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jslth/rgesis/actions/workflows/R-CMD-check.yaml)
[![R-hub](https://github.com/jslth/rgesis/actions/workflows/rhub.yaml/badge.svg)](https://github.com/jslth/rgesis/actions/workflows/rhub.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/rgesis)](https://CRAN.R-project.org/package=rgesis)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Codecov test
coverage](https://codecov.io/gh/JsLth/rgesis/branch/main/graph/badge.svg)](https://app.codecov.io/gh/JsLth/rgesis?branch=main)
[![CodeFactor](https://www.codefactor.io/repository/github/jslth/rgesis/badge/main)](https://www.codefactor.io/repository/github/jslth/rgesis/overview/main)
<!-- badges: end -->

`{rgesis}` provides a simple, programmatic and reproducible interface to
the GESIS search engine and data archive. It allows the retrieval of
metadata on records like research datasets, variables, publications, and
tools. Based on this, the package can also download survey data from the
data archive.

Note that while the GESIS search API can be accessed directly, you need
to be logged in to download any survey data. You can create a user
account
[here](https://login.gesis.org/realms/gesis/login-actions/registration?client_id=js-login).
`{rgesis}` takes over continuous credentials management and OAuth
authentication using the [`{keyring}`](https://keyring.r-lib.org/) and
[`{httr2}`](https://httr2.r-lib.org/) packages.

**Disclaimer:** This is not an official GESIS product. Not affiliated
with or endorsed by GESIS – Leibniz Institute for the Social Sciences.
Users are responsible for complying with GESIS [terms of
use](https://www.gesis.org/fileadmin/upload/dienstleistung/daten/umfragedaten/_bgordnung_bestellen/2023-06-30_Usage_regulations.pdf).

## Installation

You can install the development version of rgesis from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pkg_install("jslth/rgesis")
```

## Example

`{rgesis}` can be used to search for research data

``` r
library(rgesis)
gesis_search("allbus", type = "research_data")
#> A list of <gesis_records> with 10 records
#> <gesis_record>
#> Type: research_data
#> ID: ZA8838
#> Title: ALLBUS 2023 - DBD Add-On
#> Date: 2025
#> Persons:
#> • Binder, Barbara
#> • Linzbach, Stephan
#> • Mangold, Frank
#> • ... and 1 more
#> 
#> <gesis_record>
#> Type: research_data
#> ID: ZA5288
#> Title: ALLBUS 2021 - Soziodemographische Standardvariablen (KonsortSWD)
#> Date: 2024
#> Persons:
#> • Hadjar, Andreas
#> • Ackermann, Kathrin
#> • Auspurg, Katrin
#> • ... and 5 more
#> 
#> <gesis_record>
#> Type: research_data
#> ID: ZA5252
#> Title: German General Social Survey - ALLBUS 2016
#> Date: 2018
#> Persons:
#> • Stefan Bauernschuster
#> • Andreas Diekmann
#> • Andreas Hadjar
#> • ... and 4 more
#> # ℹ 7 more records
#> # ℹ Use `print(n = ...)` to see more records
```

… or other things from the social sciences, like publications.

``` r
gesis_search("climate change", type = "publication")
#> A list of <gesis_records> with 10 records
#> <gesis_record>
#> Type: publication
#> ID: csa-pais-2011-148719
#> Title: Migration and Climate Change
#> Date: 2011
#> Persons:
#> • Piguet, Etienne [Ed]
#> • Pecoud, Antoine [Ed]
#> • de Guchteneire, Paul [Ed]
#> 
#> <gesis_record>
#> Type: publication
#> ID: gesis-ssoar-75571
#> Title: Japan's Climate Change Discourse: Toward Climate Securitisation?
#> Date: 2021
#> Persons:
#> • Koppenborg, Florentine
#> • Hanssen, Ulv
#> 
#> <gesis_record>
#> Type: publication
#> ID: bibsonomy-noth2025epistemic
#> Title: How Epistemic Beliefs about Climate Change Predict Climate Change
#> Conspiracy Beliefs
#> Date: 2025
#> Persons:
#> • Nöth, Linnea
#> • Zander, Lysann
#> # ℹ 7 more records
#> # ℹ Use `print(n = ...)` to see more records
```

The results include metadata in complex data structures – or simplified
to a tidy rectangular shape.

``` r
gesis_search(tidy = TRUE)
#> # A tibble: 10 × 35
#>    id            title type  date  date_recency abstract portal_url topic person
#>    <chr>         <chr> <chr> <chr> <chr>        <chr>    <chr>      <lis> <list>
#>  1 gesis-ssoar-… Die … publ… 2005  2005         "'Im Ze… http://ww… <chr> <chr> 
#>  2 gesis-ssoar-… Book… publ… 2005  2005          <NA>    http://ww… <chr> <chr> 
#>  3 gesis-ssoar-… Verm… publ… 2005  2005         "\"In d… http://ww… <chr> <chr> 
#>  4 gesis-ssoar-… Reze… publ… 2006  2006          <NA>    http://ww… <chr> <chr> 
#>  5 gesis-ssoar-… Prol… publ… 1999  1999          <NA>    http://ww… <chr> <chr> 
#>  6 gesis-ssoar-… Chro… publ… 2010  2010         "Vingt … http://ww… <chr> <chr> 
#>  7 gesis-ssoar-… Bezi… publ… 2000  2000          <NA>    http://ww… <chr> <chr> 
#>  8 gesis-ssoar-… Book… publ… 2007  2007          <NA>    http://ww… <chr> <chr> 
#>  9 gesis-ssoar-… Tele… publ… 2007  2007         "The mo… http://ww… <chr> <chr> 
#> 10 gesis-ssoar-… Book… publ… 2007  2007          <NA>    http://ww… <chr> <chr> 
#> # ℹ 26 more variables: person_sort <chr>, source <chr>, subtype <chr>,
#> #   document_type <chr>, institutions <chr>, coreAuthor <list>,
#> #   coreSjahr <chr>, coreJournalTitle <chr>, coreZsband <chr>,
#> #   coreZsnummer <chr>, coreLanguage <chr>, urn <chr>, data_source <chr>,
#> #   index_source <chr>, database <chr>, link_count <int>, gesis_own <int>,
#> #   fulltext <int>, metadata_quality <int>, full_text <chr>, doi <chr>,
#> #   coreIssn <chr>, publishLocation_str_mv <chr>, coreRecensionTitle <chr>, …
```

Metadata records can also be used to download survey data directly from
the data archive. You need to be logged in, though.

``` r
# gesis_auth()
sav_file <- gesis_data("ZA5272", select = "\\.sav")
haven::read_sav(sav_file)
```

# Related packages

- [`{gesisdata}`](https://fsolt.org/gesisdata/) provides access to the
  GESIS data archive using web browser automation
- [`{mannheim}`](https://github.com/sumtxt/mannheim) and
  [`{gesis}`](https://github.com/expersso/gesis) provide direct API
  access but are outdated and do not account for the full capabilities
  of the search engine
