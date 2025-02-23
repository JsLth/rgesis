"%||%" <- function(x, y) {
  if (is.null(x)) y else x
}


"%|||%" <- function(x, y) {
  if (is.null(x) || all(is.na(x))) y else x
}


"%|T|%" <- function(x, y) {
  if (is.null(x)) {
    force(y)
  }
  x
}


"%except%" <- function(x, y) {
  x <- try(x, silent = TRUE)
  if (inherits(x, "try-error")) y else x
}


"%empty%" <- function(x, y) {
  if (!length(x)) y else x
}


drop_null <- function(x) {
  x[!vapply(x, FUN.VALUE = logical(1), is.null)]
}


unbox <- function(x) {
  if (inherits(x, "list") && length(x) == 1) {
    x <- x[[1]]
  }
  x
}


rg_stop <- function(msg, env = parent.frame(), class = NULL, ...) {
  cli::cli_abort(msg, .envir = env, class = c(class, "rg_error"), ...)
}


loadable <- function(x) {
  suppressPackageStartupMessages(requireNamespace(x, quietly = TRUE))
}


as_data_frame <- function(x) {
  if (loadable("tibble")) {
    tibble::as_tibble(x)
  } else {
    as.data.frame(x)
  }
}


rbind_list <- function(args, fill_in = NA) {
  nam <- lapply(args, names)
  unam <- unique(unlist(nam))
  len <- vapply(args, length, numeric(1))
  out <- vector("list", length(len))
  for (i in seq_along(len)) {
    if (nrow(args[[i]])) {
      nam_diff <- setdiff(unam, nam[[i]])
      if (length(nam_diff)) {
        args[[i]][nam_diff] <- fill_in
      }
    } else {
      next
    }
  }
  out <- suppressWarnings(do.call(rbind, args))
  rownames(out) <- NULL
  out
}


regex_match <- function(text, pattern, i = NULL, ...) {
  match <- regmatches(text, regexec(pattern, text, ...))
  if (!is.null(i)) {
    match <- vapply(match, FUN.VALUE = character(1), function(x) {
      if (length(x) >= i) x[[i]] else NA_character_
    })
  }
  match
}


is_dir <- function(x) {
  is.character(x) && dir.exists(x) && file.info(x)$isdir
}


as_nested_dataframe <- function(x) {
  df <- data.frame()
  for (field in names(x)) {
    if (is.atomic(x[[field]])) {
      df[[field]] <- list(x[["field"]])
    } else {
      df[[field]] <- x[["field"]]
    }
  }
  df
}


as_nested_dataframe <- function(x) {
  class(x) <- "data.frame"
  attr(x, "row.names") <- seq_len(NROW(x[[1]]))
  x
}


ask <- function(prompt) askpass::askpass(prompt)
