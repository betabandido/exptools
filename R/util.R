#' Asserts an expression
#'
#' If the expression evaluates to false then the execution stops and the given
#' message is printed.
#' @param expr The expression to evaluate.
#' @param msg The error message.
#' @examples
#' \dontrun{
#' assert(1 == 2, '1 is not equal to 2')
#' }
assert <- function(expr, msg) {
  if (!expr) stop(msg, call. = F)
}

#' Curries a function
#'
#' Curries a function. See http://en.wikipedia.org/wiki/Currying for more
#' information.
#' @param func The function to curry.
#' @param ... The parameters to use (named parameters can be used).
#' @return The curried function.
#' @export
#' @examples
#' curry(function(x, y) { x + y }, x = 1)(2) # = 3
#' curry(log, base = 2)(16) # = 4
curry <- function (func, ...) {
  .orig = list(...)
  function(...) do.call(func, c(.orig, list(...)))
}

#' List the files in a directory
#'
#' This function is similar to base::list.files but it matches the pattern
#' against the full path.
#' @param path Path where to look for files.
#' @param pattern Regular expression to be used to filter non-matching paths.
#' @return The list of files (using full paths) that match the pattern.
#' @examples
#' \dontrun{
#' .list.files('.', 'dir-\\w+/file-\\d+\\.csv')
#' }
.list.files <- function(path, pattern) {
  assert(is.character(path) && path != '',
         'path must be a non-empty string')
  assert(is.character(pattern) && pattern != '',
         'pattern must be a non-empty string')

  fname.pattern <- utils::tail(strsplit(pattern, '/')[[1]], n = 1)
  file.list <- base::list.files(path,
                                fname.pattern,
                                recursive = T,
                                full.names = T)
  if (length(file.list) > 0) {
    # Returns TRUE if the path matches the pattern. For that to happen,
    # the complete match and all the capture groups must be valid.
    matches.pattern <- function(path) {
      m <- str_match(path, pattern)
      all(is.na(m) == FALSE)
    }
    file.list <- file.list[sapply(file.list, matches.pattern)]
  }

  return(file.list)
}
