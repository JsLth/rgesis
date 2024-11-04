
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
the GESIS search engine. It allows the retrieval of metadata on records
like research datasets, variables, publications, and tools. Based on
this, the package can also download survey data from the data archive.

Note that while the GESIS search API can be accessed directly, you need
to be logged in to download any survey data. You can create a user
account
[here](https://login.gesis.org/realms/gesis/login-actions/registration?client_id=js-login).
`{rgesis}` takes over continuous credentials management and OAuth
authentication using the [`{keyring}`](https://keyring.r-lib.org/) and
[`{httr2}`](https://httr2.r-lib.org/) packages.

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
#> A list of <gesis_hits> with 10 hits
#> 
#> <gesis_hit>
#> Type: research_data
#> ID: ZA3753
#> Title: German General Social Survey - ALLBUS 1998
#> Date: 2005
#> Persons:
#> • Allerbeck, Klaus
#> • Allmendinger, Jutta
#> • Bürklin, Wilhelm
#> • Kiefer, Marie Luise
#> • Müller, Walter
#> • ... and 2 more
#> 
#> <gesis_hit>
#> Type: research_data
#> ID: ZA3702
#> Title: German General Social Survey - ALLBUS 2002
#> Date: 2008
#> Persons:
#> • Andreß, Hans-Jürgen
#> • Bürklin, Wilhelm
#> • Diekmann, Andreas
#> • Feger, Hubert
#> • Huinink, Johannes
#> • ... and 2 more
#> 
#> <gesis_hit>
#> Type: research_data
#> ID: ZA5272
#> Title: German General Social Survey - ALLBUS 2018
#> Date: 2019
#> Persons:
#> • Diekmann, Andreas
#> • Hadjar, Andreas
#> • Kurz, Karin
#> • Rosar, Ulrich
#> • Wagner, Ulrich
#> • ... and 1 more
#> # ℹ 7 more hits
#> # ℹ Use `print(n = ...)` to see more hits
```

… or other things from the social sciences, like publications.

``` r
gesis_search("climate change", type = "publication")
#> A list of <gesis_hits> with 10 hits
#> 
#> <gesis_hit>
#> Type: publication
#> ID: csa-pais-2011-148719
#> Title: Migration and Climate Change
#> Date: 2011
#> Persons:
#> • Piguet, Etienne [Ed]
#> • Pecoud, Antoine [Ed]
#> • de Guchteneire, Paul [Ed]
#> 
#> <gesis_hit>
#> Type: publication
#> ID: gesis-ssoar-75571
#> Title: Japan's Climate Change Discourse: Toward Climate Securitisation?
#> Date: 2021
#> Persons:
#> • Koppenborg, Florentine
#> • Hanssen, Ulv
#> 
#> <gesis_hit>
#> Type: publication
#> ID: fes-bib-469114
#> Title: Human rights and climate change
#> Date: 2009
#> # ℹ 7 more hits
#> # ℹ Use `print(n = ...)` to see more hits
```

The results include metadata in complex data structures – or simplified
to a tidy rectangular shape.

``` r
gesis_search(tidy = TRUE)
#> # A tibble: 10 × 31
#>    id      title type  date  date_recency abstract portal_url person person_sort
#>    <chr>   <chr> <chr> <chr> <chr>        <chr>    <chr>      <list> <chr>      
#>  1 gesis-… Glob… publ… 2008  2008         This ar… http://ww… <chr>  Forrest    
#>  2 gesis-… From… publ… 2008  2008         The art… http://ww… <chr>  Bradshaw   
#>  3 gesis-… Glob… publ… 2008  2008         Violent… http://ww… <chr>  Piachaud   
#>  4 gesis-… Cult… publ… 2005  2005         <NA>     http://ww… <chr>  Ticktin    
#>  5 gesis-… Insu… publ… 2005  2005         <NA>     http://ww… <chr>  Lowe       
#>  6 gesis-… The … publ… 2005  2005         <NA>     http://ww… <chr>  HelliwellH…
#>  7 gesis-… Kins… publ… 2005  2005         Among t… http://ww… <chr>  Yemelianova
#>  8 gesis-… Libe… publ… 2005  2005         <NA>     http://ww… <chr>  Loobuyck   
#>  9 gesis-… The … publ… 2005  2005         The foc… http://ww… <chr>  HickmanMor…
#> 10 gesis-… Excl… publ… 2005  2005         This ar… http://ww… <chr>  AndersonTa…
#> # ℹ 22 more variables: source <chr>, subtype <chr>, document_type <chr>,
#> #   institutions <chr>, coreAuthor <list>, coreSjahr <chr>,
#> #   coreJournalTitle <chr>, coreZsband <chr>, coreZsnummer <chr>,
#> #   coreLanguage <chr>, doi <chr>, urn <chr>, data_source <chr>,
#> #   index_source <chr>, database <chr>, link_count <int>, gesis_own <int>,
#> #   fulltext <int>, metadata_quality <int>, full_text <chr>, coreIssn <chr>,
#> #   topic <chr>
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
