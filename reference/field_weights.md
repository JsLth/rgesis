# Construct field weights

Construct a vector that can be used to weight metadata fields of search
records. To be used as input to the `fields` argument in
[`gesis_search`](https://jslth.github.io/rgesis/reference/gesis_search.md).

## Usage

``` r
field_weights(..., use_default = TRUE)
```

## Arguments

- ...:

  Key-value pairs where the key is the name of the field and the value
  is the weight.

- use_default:

  Whether to use a sensible default when passing nothing to `...`.

## Value

A character vector of field weights.

## Examples

``` r
# use default weights
field_weights()
#>  [1] "title^10"            "topic^7"             "abstract^3"         
#>  [4] "source^3"            "title_en^10"         "topic_en^7"         
#>  [7] "abstract_en^3"       "id"                  "title.partial^0.4"  
#> [10] "topic.partial^0.2"   "content.partial^0.2" "id.partial^0.4"     
#> [13] "full_text^0.1"      

# set a stronger weight on the abstract
field_weights(abstract = 5)
#> [1] "abstract^5"

# set no weights
field_weights(use_default = FALSE)
#> character(0)
```
