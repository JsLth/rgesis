
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
[`{httr2}`](https://httr2.r-lib.org/) packages. By downloading data from
the GESIS data archive, you agree to its [terms of
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
#> ID: ZA5288
#> Title: ALLBUS 2021 - Soziodemographische Standardvariablen (KonsortSWD)
#> Date: 2024
#> Persons:
#> • Hadjar, Andreas
#> • Ackermann, Kathrin
#> • Auspurg, Katrin
#> • Bühler, Christoph
#> • Carol, Sarah
#> • ... and 3 more
#> 
#> <gesis_record>
#> Type: research_data
#> ID: ZA8838
#> Title: ALLBUS 2023 - DBD Add-On
#> Date: 2025
#> Persons:
#> • Binder, Barbara
#> • Linzbach, Stephan
#> • Mangold, Frank
#> • Schmidt, Felix
#> 
#> <gesis_record>
#> Type: research_data
#> ID: SDN-10.7802-2497
#> Title: Code/Syntax: The role of values as mediator in relationships between
#> social position and cultural omnivorousness in Germany [Replication files]
#> Date: 2022
#> Person:
#> • Voronin, Yevhen
#> 
#> <gesis_record>
#> Type: research_data
#> ID: ZA2140
#> Title: Allgemeine Bevölkerungsumfrage der Sozialwissenschaften ALLBUS 1992
#> Date: 2014
#> Persons:
#> • Allerbeck, Klaus R.
#> • Allmendinger, Jutta
#> • Müller, Walter
#> • Opp, Karl-Dieter
#> • Pappi, Franz U.
#> • ... and 2 more
#> 
#> <gesis_record>
#> Type: research_data
#> ID: ZA4616
#> Title: German General Social Survey - ALLBUS 2012
#> Date: 2019
#> Persons:
#> • Diekmann, Andreas
#> • Fetchenhauer, Detlef
#> • Kühnel, Steffen
#> • Liebig, Stefan
#> • Schmitt-Beck, Rüdiger
#> • ... and 2 more
#> # ℹ 5 more records
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
#> ID: fes-bib-469114
#> Title: Human rights and climate change
#> Date: 2009
#> 
#> <gesis_record>
#> Type: publication
#> ID: gesis-ssoar-76642
#> Title: Attitudes towards climate change migrants
#> Date: 2020
#> Person:
#> • Helbling, Marc
#> 
#> <gesis_record>
#> Type: publication
#> ID: gesis-bib-153820-LP
#> Title: Climate Change : Fieldwork: April 2019
#> Date: 2019
#> # ℹ 5 more records
#> # ℹ Use `print(n = ...)` to see more records
```

The results include metadata in complex data structures – or simplified
to a tidy rectangular shape.

``` r
gesis_search(tidy = TRUE)
#> # A tibble: 10 × 33
#>    id            title type  date  date_recency abstract portal_url topic person
#>    <chr>         <chr> <chr> <chr> <chr>        <chr>    <chr>      <lis> <list>
#>  1 gesis-ssoar-… Muje… publ… 2010  2010         "The ca… http://ww… <chr> <chr> 
#>  2 gesis-ssoar-… Rußl… publ… 1999  1999         "'Durch… http://ww… <chr> <chr> 
#>  3 gesis-ssoar-… Prob… publ… 1999  1999         "'Die I… http://ww… <chr> <chr> 
#>  4 gesis-ssoar-… Ukra… publ… 1995  1995          <NA>    http://ww… <chr> <chr> 
#>  5 gesis-ssoar-… Prob… publ… 2002  2002         "Vor nu… http://ww… <chr> <chr> 
#>  6 gesis-ssoar-… Migr… publ… 2002  2002         "\"Als … http://ww… <chr> <chr> 
#>  7 gesis-ssoar-… Staa… publ… 2002  2002         "Im vor… http://ww… <chr> <chr> 
#>  8 gesis-ssoar-… Wahl… publ… 2001  2001         "\"Die … http://ww… <chr> <chr> 
#>  9 gesis-ssoar-… Ener… publ… 2001  2001         "Ebenso… http://ww… <chr> <chr> 
#> 10 gesis-ssoar-… Iden… publ… 2008  2008         "Events… http://ww… <chr> <chr> 
#> # ℹ 24 more variables: person_sort <chr>, source <chr>, subtype <chr>,
#> #   document_type <chr>, institutions <chr>, coreAuthor <list>,
#> #   coreSjahr <chr>, coreJournalTitle <chr>, coreZsband <chr>,
#> #   coreZsnummer <chr>, coreLanguage <chr>, urn <chr>, coreIssn <chr>,
#> #   data_source <chr>, index_source <chr>, database <chr>, link_count <int>,
#> #   gesis_own <int>, fulltext <int>, metadata_quality <int>, full_text <chr>,
#> #   coreCorpEditor <chr>, publishLocation_str_mv <chr>, doi <chr>
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
