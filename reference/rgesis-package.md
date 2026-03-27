# rgesis: Interface to GESIS Search

Provides programmatic access to the GESIS Search engine
<https://search.gesis.org/> to retrieve metadata on research data,
variables, literature, and tools. Authenticate and download datasets
from the GESIS data archive with minimal dependencies.

## Global options

A number of global options can be set that change the behavior of
package functions. These include:

- `rgesis_cache_disk`:

  If `TRUE`, stores OAuth access tokens in the `httr2` cache. This
  prevents repeated authentication using credentials but stores access
  credentials on the disk. Defaults to `FALSE`.

- `rgesis_debug`:

  Whether to echo GET requests before they are sent. Defaults to FALSE.

- `rgesis_download_purpose`:

  Download purpose that must be specified before downloading any kind of
  data from the GESIS catalogue. This option is a way to specify a
  download purpose globally to prevent having to pass it as an argument
  to each call of
  [`gesis_data`](https://jslth.github.io/rgesis/reference/gesis_data.md).

## See also

Useful links:

- <https://github.com/jslth/rgesis/>

- <https://jslth.github.io/rgesis/>

- Report bugs at <https://github.com/jslth/rgesis/issues>

## Author

**Maintainer**: Jonas Lieth <jonas.lieth@gesis.org>
([ORCID](https://orcid.org/0000-0002-3451-3176)) \[copyright holder\]
