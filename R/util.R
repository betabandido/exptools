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
