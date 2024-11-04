ignore_null <- function() {
  args <- parent.frame()
  if (is.null(args$x) && isTRUE(args$null)) {
    return_from_parent(NULL, .envir = parent.frame())
  }
}


get_caller_name <- function(parent = sys.parent()) {
  deparse(sys.call(parent)[[1]])
}


return_from_parent <- function(obj, .envir = parent.frame()) {
  do.call("return", args = list(obj), envir = .envir)
}


match_arg <- function(arg, choices, several.ok = FALSE, null = FALSE) {
  if (is.null(arg) && null) {
    return()
  }
  match.arg(arg, choices, several.ok = several.ok)
}


assert_keyring_support <- function() {
  cond <- keyring::has_keyring_support()
  if (!cond) {
    rg_stop("System does not have keyring support. Cannot store credentials.")
  }
}


assert_vector <- function(x, ptype = NULL, size = NULL, null = FALSE) {
  ignore_null()
  cond <- is.atomic(x) && typeof(x) == ptype
  if (!is.null(ptype) && !cond) {
    var <- deparse(substitute(x))
    rg_stop(
      "{.code {var}} must be an atomic vector of type {.cls {ptype}}, not {.cls {typeof(x)}}.",
      class = get_caller_name()
    )
  }

  cond <- length(x) == size
  if (!is.null(size) && !cond) {
    var <- deparse(substitute(x))
    rg_stop(
      "{.code {var}} must be an atomic vector of size {size}, not {length(x)}.",
      class = get_caller_name()
    )
  }
}


assert_flag <- function(x, null = FALSE) {
  ignore_null()
  cond <- is.logical(x) && !is.na(x)
  if (!cond) {
    var <- deparse(substitute(x))
    rg_stop(
      "{.code {var}} must be a vector consisting only of TRUE or FALSE.",
      class = get_caller_name()
    )
  }
}


assert_class <- function(x, class, null = FALSE) {
  ignore_null()
  cond <- any(class %in% class(x))
  if (!cond) {
    var <- deparse(substitute(x))
    class <- cli::cli_vec(class, style = list("vec-last" = " or "))
    rg_stop(
      "{.code {var}} must be of class {class}, not {.cls {class(x)}}.",
      class = get_caller_name()
    )
  }
}
