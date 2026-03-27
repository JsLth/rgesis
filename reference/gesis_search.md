# GESIS Search

Query the GESIS search engine to retrieve metadata on research data,
variables, tools, publications, libraries, and websites.

## Usage

``` r
gesis_search(
  query = NULL,
  type = NULL,
  default_operator = "AND",
  fields = field_weights(),
  sort = "relevance",
  publication_year = NULL,
  countries = NULL,
  topics = NULL,
  authors = NULL,
  sources = NULL,
  study_title = NULL,
  study_group = NULL,
  collection_year = NULL,
  thematic_collections = NULL,
  method_data_collection = NULL,
  method_sampling = NULL,
  method_time = NULL,
  method_unit = NULL,
  data_type = NULL,
  interview_language = NULL,
  pages = 1,
  tidy = FALSE
)

# S3 method for class 'gesis_records'
as.data.frame(x, ...)
```

## Arguments

- query:

  The search term to query. Terms can be seperated by operators OR /
  AND. If no operator is specified, defaults to the operator specified
  in `default_operator`. If `NULL`, searches for all records. Queryless
  searches can still be filtered using the parameters below.

- type:

  Type of search results to retrieve. Can be one of the following:

  - `research_data`: Survey data records

  - `variables`: Variables related to survey data records

  - `instruments_tools`: Measurement instruments like items, scales,
    questionnaires, tests, and indexes offered by
    [ZIS](https://zis.gesis.org/).

  - `publication`: Publications like journal articles or book chapters

  - `gesis_bib`: Records from the [GESIS
    library](https://www.gesis.org/en/institute/about-us/departments/knowledge-transfer/library)

  - `gesis_web`: GESIS websites

  - `gesis_person`: Institutional websites of GESIS employees

  If `NULL`, includes all result types. Defaults to `NULL`.

- default_operator:

  Character specifying the default operator to use as seperator of
  search terms. Can be `"AND"` or `"OR"`. Defaults to `"AND"`. Ignored
  if `query` is `NULL`.

- fields:

  Character vector of field weights as returned by
  [`field_weights`](https://jslth.github.io/rgesis/reference/field_weights.md).
  Used to specify how much weight is given to query matches in certain
  metadata fields. The higher the weight, the more a field influences
  the match probability. Defaults to the default values specified by
  [`field_weights`](https://jslth.github.io/rgesis/reference/field_weights.md).
  Ignored if `query` is `NULL`.

- sort:

  Attribute to sort by. Must be one of the following:

  - `relevance`: Sorts by relevance (whatever that means)

  - `newest_first`: Sorts by publication year, descending

  - `oldest_first`: Sorts by publication year, ascending

  - `title_ascending`: Sorts lexicographically by title, ascending

  - `title_descending`: Sorts lexicographically by title, descending

  - `variable_ascending`: Sorts lexicographically by variable name,
    ascending

  - `variable_descending`: Sorts lexicographically by variable name,
    descending

  Defaults to `"relevance"` to mirror the behavior of the web interface.

- publication_year:

  Numeric or character vector of length 2 specifying the time range in
  which a record was published. The first value is the start year and
  the second value is the end year. If `NULL`, returns records from all
  years. Defaults to `NULL`.

- countries:

  Character vector specifying the country in which the record was
  published. If `NULL`, returns records from all countries. Defaults to
  `NULL`.

- topics:

  Character vector specifying the topics to filter by. Example values
  include "Political behavior and attitudes" or "Migration". See
  <https://search.gesis.org/> for a full list of possible topics.

- authors:

  Character vector specifying the authors to filter by.

- sources:

  Character vector specifying the source of the record.

- study_title:

  Character vector specifying the study title. Only sensible for
  research data or variables.

- study_group:

  Character vector specifying the study group. Only sensible for
  research data or variables.

- collection_year:

  Numeric or character vector of length 2 specifying the time range in
  which a dataset was collected. The first value is the start year and
  the second value is the end year. If `NULL`, returns records from all
  years. Defaults to `NULL`. Only sensible for research data or
  variables.

- thematic_collections:

  Character vector specifying the thematic collection a dataset or
  variable belongs to. Example values include "COVID-19" or "Environment
  and climate". See <https://search.gesis.org/> for a full list of
  possible topics.

- method_data_collection, method_sampling, method_time, method_unit:

  Arguments to filter by the methodology used in a study. It is possible
  to filter by the mode of data collection (`method_data_collection`),
  sampling procedure (`method_sampling`), temporal research design
  (`method_unit`) and analysis unit (`method_unit`). Only sensible for
  research data and variables.

- data_type:

  Character vector specifying the data type of a dataset or variable.
  Example values include `"numeric"`, `"geospatial"`, and `"text"`. Only
  sensible for research data and variables.

- interview_language:

  Character vector specifying the interview language of a variable.
  Usually only `"german"` and `"english"` are available. Only sensible
  for variables.

- pages:

  Numeric vector specifying the page numbers of the search results. By
  default, only the first page is returned. If `NULL`, iterates through
  all pages.

- tidy:

  If `TRUE`, returns the records in a rectangular shape that can be
  wrangled more easily. In this form, some more complex metadata fields
  that cannot be converted to a rectangular shapre are discarded. If
  `FALSE`, returns the records as a list-like `gesis_records` object.
  This object is more comprehensive, but harder to work with. Defaults
  to `FALSE`.

- x:

  Object of class `gesis_records`

- ...:

  Arguments passed on to the respective S3 methods.

## Value

If `tidy = FALSE`, returns an object of class `gesis_records` consisting
of multiple objects of class `gesis_record`. Each `gesis_record`
contains attributes `index`, `id`, and `score` specifying the index, the
record ID, and the match score.

If `tidy = TRUE`, returns a dataframe or tibble where each row is a
record and each column is a metadata field.

In any case, the query used to retrieve the data is stored in the
attribute `query`.

## Examples

``` r
# Make a queryless search across the entire database and return
# the first 10 results
gesis_search()
#> A list of <gesis_records> with 10 records
#> <gesis_record>
#> Type: publication
#> ID: gesis-ssoar-27818
#> Title: Die Macht der Verhältnisse und die Stärke des Subjekts: eine Studie über
#> ostdeutsche Manager vor und nach 1989 ; zugleich eine biographietheoretische
#> Erklärung für Stabilität und Instabilität der DDR
#> Date: 2005
#> Persons:
#> • Nagel, Ulrike
#> • Teipen, Christina
#> • Velez, Andrea
#> 
#> <gesis_record>
#> Type: publication
#> ID: gesis-ssoar-22385
#> Title: Book Review: The Genetic Imaginary: DNA in the Canadian Criminal Justice
#> System
#> Date: 2005
#> Person:
#> • Benecke, Mark
#> 
#> <gesis_record>
#> Type: publication
#> ID: gesis-ssoar-31770
#> Title: Vermittlungsgutscheine: Zwischenergebnisse der Begleitforschung 2004. T.
#> 1, Datenstruktur und deskriptive Analysen
#> Date: 2005
#> Persons:
#> • Heinze, Anja
#> • Pfeiffer, Friedhelm
#> • Spermann, Alexander
#> • ... and 2 more
#> # ℹ 7 more records
#> # ℹ Use `print(n = ...)` to see more records

# Queries can be narrowed down by providing a query string
record <- gesis_search("climate change")

# gesis_search() searches for all types of records by default. If you only
# want to search for, say, datasets, you can set the `type` argument.
gesis_search(type = "research_data")
#> A list of <gesis_records> with 10 records
#> <gesis_record>
#> Type: research_data
#> ID: ZA4580
#> Title: German General Social Survey (ALLBUS) - Cumulation 1980-2012
#> Date: 2014
#> Persons:
#> • Allerbeck, Klaus
#> • Allmendinger, Jutta
#> • Andreß, Hans-Jürgen
#> • ... and 23 more
#> 
#> <gesis_record>
#> Type: research_data
#> ID: ZA6249
#> Title: Sächsische Längsschnittstudie - Welle 31, 2019
#> Date: 2020
#> Persons:
#> • Förster, Peter
#> • Brähler, Elmar
#> • Stöbel-Richter, Yve
#> • ... and 2 more
#> 
#> <gesis_record>
#> Type: research_data
#> ID: ZA1571
#> Title: Typologie der Wünsche 1986
#> Date: 1987
#> Person:
#> • BURDA Marktforschung, Offenburg
#> # ℹ 7 more records
#> # ℹ Use `print(n = ...)` to see more records

# By default, only 10 results (1 page) are returned. You can specify
# which pages should queried or if all should be returned
gesis_search("climate change", pages = 2:3) # pages 2 and 3
#> A list of <gesis_records> with 20 records
#> <gesis_record>
#> Type: variables
#> ID: exploredata-ZA3850_VarV195
#> Title: V195 - HOCHWASSER:KLIMAVERäND.?
#> Date: 2003
#> 
#> <gesis_record>
#> Type: variables
#> ID: exploredata-ZA6802_Varvn64
#> Title: vn64 - Salienz Klimawandel
#> Date: 2019
#> 
#> <gesis_record>
#> Type: variables
#> ID: exploredata-ZA6805_Varkp4_1290
#> Title: kp4_1290 - Klimaschutz, Ego
#> Date: 2019
#> # ℹ 17 more records
#> # ℹ Use `print(n = ...)` to see more records
if (FALSE) gesis_search("climate change", pages = NULL) # all pages

# By default, results are wrapped in a complex list structure. This is
# good for representing detailed information, but not for analyzing data.
# Results can be tidied up to a dataframe using either `as_tibble()`
# or by setting the `tidy` argument to TRUE
tibble::as_tibble(record)
#> # A tibble: 10 × 83
#>    id             title type  date  title_en study_id study_title study_title_en
#>    <chr>          <chr> <chr> <chr> <chr>    <chr>    <chr>       <chr>         
#>  1 exploredata-Z… vg1.… vari… 2016  vg1.14 … ZA5978   Youth Stud… Youth Study M…
#>  2 exploredata-Z… q72 … vari… 2019  q72 - S… ZA5700   Vorwahl-Qu… Pre-election …
#>  3 exploredata-Z… V195… vari… 2003  V195 - … ZA3849   Politbarom… Politbaromete…
#>  4 exploredata-Z… kpa1… vari… 2019  kpa1_12… ZA6804   Wahlkampf-… Short-term Ca…
#>  5 exploredata-Z… V893… vari… 2013  V893 - … ZA4612   German Gen… German Genera…
#>  6 exploredata-Z… G113… vari… 2016  G113 - … ZA5976   Youth in a… Youth in a Ti…
#>  7 exploredata-Z… vn72… vari… 2019  vn72 - … ZA5702   Vor- und N… Pre- and Post…
#>  8 exploredata-Z… kp2_… vari… 2019  kp2_129… ZA6804   Wahlkampf-… Short-term Ca…
#>  9 exploredata-Z… kp4_… vari… 2019  kp4_130… ZA6804   Wahlkampf-… Short-term Ca…
#> 10 exploredata-Z… kp8_… vari… 2019  kp8_129… ZA6804   Wahlkampf-… Short-term Ca…
#> # ℹ 75 more variables: variable_label <chr>, variable_label_en <chr>,
#> #   variable_name <chr>, variable_name_sorting <chr>, variable_code_list <chr>,
#> #   variable_interview_instructions_en <chr>, study_id_title <chr>,
#> #   study_id_title_en <chr>, date_recency <int>,
#> #   time_collection_max_year <int>, time_collection_min_year <int>,
#> #   time_collection_years <chr>, countries_collection <list>,
#> #   methodology_collection_ddi <list>, selection_method_ddi <list>, …
gesis_search("climate change", tidy = TRUE)
#> # A tibble: 10 × 83
#>    id             title type  date  title_en study_id study_title study_title_en
#>    <chr>          <chr> <chr> <chr> <chr>    <chr>    <chr>       <chr>         
#>  1 exploredata-Z… vg1.… vari… 2016  vg1.14 … ZA5978   Youth Stud… Youth Study M…
#>  2 exploredata-Z… q72 … vari… 2019  q72 - S… ZA5700   Vorwahl-Qu… Pre-election …
#>  3 exploredata-Z… V195… vari… 2003  V195 - … ZA3849   Politbarom… Politbaromete…
#>  4 exploredata-Z… kpa1… vari… 2019  kpa1_12… ZA6804   Wahlkampf-… Short-term Ca…
#>  5 exploredata-Z… V893… vari… 2013  V893 - … ZA4612   German Gen… German Genera…
#>  6 exploredata-Z… G113… vari… 2016  G113 - … ZA5976   Youth in a… Youth in a Ti…
#>  7 exploredata-Z… vn72… vari… 2019  vn72 - … ZA5702   Vor- und N… Pre- and Post…
#>  8 exploredata-Z… kp2_… vari… 2019  kp2_129… ZA6804   Wahlkampf-… Short-term Ca…
#>  9 exploredata-Z… kp4_… vari… 2019  kp4_130… ZA6804   Wahlkampf-… Short-term Ca…
#> 10 exploredata-Z… kp8_… vari… 2019  kp8_129… ZA6804   Wahlkampf-… Short-term Ca…
#> # ℹ 75 more variables: variable_label <chr>, variable_label_en <chr>,
#> #   variable_name <chr>, variable_name_sorting <chr>, variable_code_list <chr>,
#> #   variable_interview_instructions_en <chr>, study_id_title <chr>,
#> #   study_id_title_en <chr>, date_recency <int>,
#> #   time_collection_max_year <int>, time_collection_min_year <int>,
#> #   time_collection_years <chr>, countries_collection <list>,
#> #   methodology_collection_ddi <list>, selection_method_ddi <list>, …

# Using the fields argument you can control how different text fields
# are weighted in matching the query string.
# Search for "climate change" only in texts, not in other fields
gesis_search("climate change", fields = field_weights(
  full_text = 10,
  abstract_en = 5,
  abstract = 3
))
#> A list of <gesis_records> with 10 records
#> <gesis_record>
#> Type: publication
#> ID: gesis-ssoar-22412
#> Title: Does tomorrow ever come? Disaster narrative and public perceptions of
#> climate change
#> Date: 2006
#> Persons:
#> • Lowe, Thomas
#> • Brown, Katrina
#> • Dessai, Suraje
#> • ... and 3 more
#> 
#> <gesis_record>
#> Type: publication
#> ID: gesis-ssoar-43950
#> Title: Can affluence explain public attitudes towards climate change mitigation
#> policies? A multilevel analysis with data from 27 EU countries
#> Date: 2014
#> Person:
#> • Sasko, David
#> 
#> <gesis_record>
#> Type: publication
#> ID: gesis-ssoar-36454
#> Title: Modifying the 2° C target: climate policy objectives in the contested
#> terrain of scientific policy advice, political preferences, and rising
#> emissions
#> Date: 2013
#> Person:
#> • Geden, Oliver
#> # ℹ 7 more records
#> # ℹ Use `print(n = ...)` to see more records

# Search for articles in a specified journal
gesis_search("urban planning", fields = field_weights(coreJournalTitle = 10))
#> A list of <gesis_records> with 10 records
#> <gesis_record>
#> Type: publication
#> ID: gesis-ssoar-70580
#> Title: Built environment, ethics and everyday life
#> Date: 2020
#> Persons:
#> • Kärrholm, Mattias
#> • Kopljar, Sandra
#> 
#> <gesis_record>
#> Type: publication
#> ID: gesis-ssoar-71915
#> Title: City Planning and Green Infrastructure: Embedding Ecology into Urban
#> Decision-Making (Editorial)
#> Date: 2021
#> Persons:
#> • Osmond, Paul
#> • Wilkinson, Sara
#> 
#> <gesis_record>
#> Type: publication
#> ID: gesis-ssoar-72488
#> Title: The Hybrid Space of Collaborative Location-Based Mobile Games and the
#> City: A Case Study of Ingress
#> Date: 2020
#> Persons:
#> • Sengupta, Ulysses
#> • Tantoush, Mahmud
#> • Bassanino, May
#> • ... and 1 more
#> # ℹ 7 more records
#> # ℹ Use `print(n = ...)` to see more records

# Search strings are separated by an AND operator by default
# this default can be overwritten by setting default_operator = "OR"
# or by manually separating the query string
weight <- field_weights(title = 100)
and <- gesis_search(
  "climate change",
  sort = "title_ascending",
  fields = weight
)
or1 <- gesis_search(
  "climate OR change",
  sort = "title_ascending",
  fields = weight
)
or2 <- gesis_search(
  "climate change",
  sort = "title_ascending",
  default_operator = "OR",
  fields = weight
)
attr(and, "query") <- NULL
attr(or1, "query") <- NULL
attr(or2, "query") <- NULL
identical(and, or1)
#> [1] FALSE
identical(or1, or2)
#> [1] TRUE

# Similarly, you can construct complex query terms using operators
gesis_search("(climate or environmental) AND (change OR crisis OR action)")
#> A list of <gesis_records> with 10 records
#> <gesis_record>
#> Type: variables
#> ID: exploredata-ZA6289_Varbc5_4
#> Title: bc5_4 - environmental info lack: climate change
#> Date: 2016
#> 
#> <gesis_record>
#> Type: variables
#> ID: exploredata-ZA6289_Varbc4_4
#> Title: bc4_4 - environmental worries: climate change
#> Date: 2016
#> 
#> <gesis_record>
#> Type: publication
#> ID: gesis-ssoar-95723
#> Title: Environmental awareness: The case of climate change
#> Date: 2018
#> Persons:
#> • Weber, Shlomo
#> • Wiesmeth, Hans
#> # ℹ 7 more records
#> # ℹ Use `print(n = ...)` to see more records

# Another way to narrow down the search is to set filters. GESIS Search
# offers a number of filters, including topic, publication year or
# methodology. Sensible values can be checked on https://search.gesis.org/.
gesis_search(topics = "climate change", type = "publication")
#> A list of <gesis_records> with 0 records
```
