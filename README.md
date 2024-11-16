
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
#> A list of <gesis_records> with 10 records
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
#> 
#> <gesis_record>
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
#> <gesis_record>
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
#> <gesis_record>
#> Type: research_data
#> ID: ZA5270
#> Title: Allgemeine Bevölkerungsumfrage der Sozialwissenschaften ALLBUS 2018
#> Date: 2019
#> Persons:
#> • Diekmann, Andreas
#> • Hadjar, Andreas
#> • Kurz, Karin
#> • Rosar, Ulrich
#> • Wagner, Ulrich
#> • ... and 1 more
#> # ℹ 5 more records
#> # ℹ Use `print(n = ...)` to see more records
```

… or other things from the social sciences, like publications.

``` r
gesis_search("climate change", type = "publication")
#> A list of <gesis_records> with 10 records
#> 
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
#> ID: bibsonomy-goughietal2008climate
#> Title: Climate Change and Social Policy
#> Date: 2008
#> Person:
#> • Gough, I. et al
#> # ℹ 5 more records
#> # ℹ Use `print(n = ...)` to see more records
```

The results include metadata in complex data structures – or simplified
to a tidy rectangular shape.

``` r
gesis_search(tidy = TRUE)
#> # A tibble: 10 × 56
#>    id       title type  date  date_recency abstract abstract_en portal_url doi  
#>    <chr>    <chr> <chr> <chr> <chr>        <chr>    <chr>       <chr>      <chr>
#>  1 zis198   Eins… inst… 1998  1998         "Die hi… The items … https://z… http…
#>  2 gesis-s… Univ… publ… 2003  2003         "\"Die … <NA>        http://ww… <NA> 
#>  3 gesis-s… 'Con… publ… 2006  2006          <NA>    <NA>        http://ww… <NA> 
#>  4 gesis-s… A ed… publ… 2000  2000         "Estudo… <NA>        http://ww… <NA> 
#>  5 gesis-s… Wahl… publ… 2007  2007         "Nach J… <NA>        http://ww… <NA> 
#>  6 gesis-s… The … publ… 2014  2014         "In Dec… <NA>        http://ww… <NA> 
#>  7 gesis-s… Dive… publ… 2000  2000         "Este a… <NA>        http://ww… <NA> 
#>  8 gesis-s… Reze… publ… 2012  2012          <NA>    <NA>        http://ww… <NA> 
#>  9 gesis-s… Konf… publ… 2004  2004          <NA>    <NA>        http://ww… <NA> 
#> 10 gesis-s… Reze… publ… 2004  2004          <NA>    <NA>        http://ww… <NA> 
#> # ℹ 47 more variables: topic <list>, topic_en <chr>, subject <chr>,
#> #   subject_en <chr>, person <list>, person_sort <chr>, source <chr>,
#> #   subtype <chr>, zis_date <chr>, count_items <chr>, validity <chr>,
#> #   construct <chr>, language_documentation <chr>, language_items <chr>,
#> #   language_items_en <chr>, author_website <chr>, data_archiv_website <chr>,
#> #   item_in_socialsurvey <chr>, status_instrument <chr>, instrument <chr>,
#> #   theory <chr>, development <chr>, quality_criteria <chr>, …
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
