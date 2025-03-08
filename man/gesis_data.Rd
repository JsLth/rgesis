% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/gesis_data.R
\name{gesis_data}
\alias{gesis_data}
\title{Download survey data}
\usage{
gesis_data(
  record,
  download_purpose = NULL,
  path = tempdir(),
  type = "dataset",
  select = NULL,
  prompt = interactive()
)
}
\arguments{
\item{record}{Object of class \code{gesis_record} as returned by
\code{\link{gesis_search}} and \code{gesis_get} or dataset ID. If a dataset ID
is passed, the function performs a call to \code{\link{gesis_get}}.}

\item{download_purpose}{Purpose for the use of the research data. You are
required to use the downloaded data solely for the specified purpose
(see also the
\href{https://www.gesis.org/fileadmin/upload/dienstleistung/daten/umfragedaten/_bgordnung_bestellen/2023-06-30_Usage_regulations.pdf}{terms of use}).
The following values are supported:

\itemize{
\item{\code{final_thesis}: for final thesis of the study programme (e.g. Bachelor/Master thesis)}
\item{\code{commercial_research}: for research with a commercial mission}
\item{\code{non_scientific}: for non-scientific purposes}
\item{\code{further_education}: for further education and qualification}
\item{\code{scientific_research}: for scientific research (incl. doctorate)}
\item{\code{studies}: in the course of my studies}
\item{\code{lecturer}: in a course as a lecturer}
}}

\item{path}{Path where the downloaded file should be stored. Can be path
to a directory or a file. If a directory path, it is attempted to infer the
file name from the file to be downloaded. If this is not possible, the file
is stored in a file called \code{gesis} with no file extension. If a file
path is passed, the file is directly downloaded to this path. Defaults to
a temporary directory path.}

\item{type}{Type of data to download. The following values are supported:

\itemize{
\item{\code{dataset}: Survey dataset, usually in a Stata or SPSS data format}
\item{\code{questionnaire}: Survey questionnaire, usually in PDF format}
\item{\code{codebook}: Survey codebook, usually in PDF format}
\item{\code{syntax}: Code files, e.g. for replication or data cleaning}
\item{\code{otherdocs}: Other files like READMEs, method
reports, or variable lists, usually in PDF format}
\item{\code{uncategorized}: Other files that are not categorized, usually
used for external links to full texts (DOI, URN)}
}

Defaults to \code{"dataset"} because downloading PDF or HTML files rarely
makes sense in R. A list of available data types for a given record can be
retrieved using \code{\link{gesis_file_types}}.}

\item{select}{Character vector to select a data file in case multiple files
are available for the selected data type. The character string is
matched against the file label using regular expressions. This argument
can also be used to match explicitly for file extensions, e.g.
\code{"\\\\.sav"} or \code{"\\\\.dat"}. Can also be of length > 1 in which
case the regular expressions are matched in the order of their index
positions. A list of file labels for a given record can be retrieved using
\code{\link{gesis_files}}. If \code{NULL}, multiple files are detected, and
the session is interactive, prompts the user to select a file. Defaults to
\code{NULL}.}

\item{prompt}{If \code{TRUE}, allows the function to open an interactive
prompt in case multiple files are found and \code{select} is either
\code{NULL} or fails to select a file unambiguously. If \code{FALSE},
throws an error in such a case. Defaults to \code{TRUE} if run in an
interactive session.}
}
\value{
The path to the downloaded file. Depending on the selected file,
there are different ways to read the file contents. Traditionally, data
files are offered in Stata and SPSS file formats and can be read using the
\href{https://haven.tidyverse.org/}{haven} package.
}
\description{
Downloads survey data from GESIS given a record or a dataset ID. To download
data, the session must be authenticated using \code{\link{gesis_auth}}.

By downloading data from the GESIS data archive, you agree to its
\href{https://www.gesis.org/fileadmin/upload/dienstleistung/daten/umfragedaten/_bgordnung_bestellen/2023-06-30_Usage_regulations.pdf}{terms of use}.
This function is intended to be used for singular, programmatic access to
survey datasets. Please refrain from using it for large-scale batch
downloads.
}
\details{
Access and refresh tokens are automatically attached to the requests sent
if possible. This is done only for URLs pointing to the domain gesis.org
to avoid sending authentication information to other domains.
}
\examples{
\dontrun{
# retrieve a search record to pass on to gesis_data()
record <- gesis_search(
  "allbus",
  publication_year = c(2019, 2020),
  type = "research_data"
)

# in interactive mode, the function can be run without arguments
path <- gesis_data(record[[1]])

# in other cases, certain arguments should be provided
path <- gesis_data(record[[1]], download_purpose = "non_scientific", select = "\\\\.sav")

# you can also simply pass a dataset ID
path <- gesis_data("ZA3753", select = "\\\\.por")

# data files must be read using other tools and packages, e.g. haven
haven::read_por(path)

# ... or pdftools
path <- gesis_data("ZA3753", select = "fb\\\\.pdf", type = "questionnaire")
pdftools::pdf_text(path)

# In some cases, a single selection regex might be difficult to work
# with, e.g., if multiple files with the same format exist.
# In this case, you may pass multiple regular expressions which are
# evaluated back by back
gesis_data(
  "ZA7716",
  select = c("\\\\.sav", "main"),
  download_purpose = "non_scientific"
)

# `gesis_data` can be used to download and execute R code
record <- gesis_get("SDN-10.7802-2109")
parse(gesis_data(record, type = "syntax", select = "car_ref_all"))}
}
