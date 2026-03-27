# Get a GESIS record

Performs a simple lookup of one or multiple specific GESIS record ID and
retrieves their metadata record from the data archive.

## Usage

``` r
gesis_get(ids)
```

## Arguments

- ids:

  Dataset IDs of the records.

## Value

An object of class `gesis_record`.

## Examples

``` r
# retrieve metadata on the ALLBUS microdata record
gesis_get("ZA5262")
#> <gesis_record>
#> Type: research_data
#> ID: ZA5262
#> Title: Allgemeine Bevölkerungsumfrage der Sozialwissenschaften ALLBUS -
#> Kleinräumige Geodaten 2014, 2016 und 2018
#> Date: 2021
#> Persons:
#> • Stefan Bauernschuster
#> • Andreas Diekmann
#> • Detlef Fetchenhauer
#> • ... and 8 more

# retrieve ALLBUS 2014, 2016, and 2018
gesis_get(c("ZA5240", "ZA5250", "ZA5270"))
#> A list of <gesis_records> with 3 records
#> <gesis_record>
#> Type: research_data
#> ID: ZA5240
#> Title: Allgemeine Bevölkerungsumfrage der Sozialwissenschaften ALLBUS 2014
#> Date: 2018
#> Persons:
#> • Andreas Diekmann
#> • Detlef Fetchenhauer
#> • Frauke Kreuter
#> • ... and 4 more
#> 
#> <gesis_record>
#> Type: research_data
#> ID: ZA5250
#> Title: Allgemeine Bevölkerungsumfrage der Sozialwissenschaften ALLBUS 2016
#> Date: 2017
#> Persons:
#> • Stefan Bauernschuster
#> • Andreas Diekmann
#> • Andreas Hadjar
#> • ... and 4 more
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
#> • ... and 3 more
```
