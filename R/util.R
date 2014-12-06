#' Asserts an expression
#' 
#' If the expression evaluates to false then the execution stops and the given
#' message is printed. 
#' @param expr The expression to evaluate.
#' @param msg The error message.
#' @examples
#' assert(1 == 2, '1 is not equal to 2')
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
