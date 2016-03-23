#' Parses a file name and returns the values for the requested fields
#' 
#' This function parses a file name and matches the name to the given pattern.
#' Then it extracts the values for the requested files.
#' @param fname file name.
#' @param pattern Regular expression used to extract the fields values.
#' @param fields Fields that uniquely identify the data from a file.
#' @return A list containing the field names and their values.
#' @import stringr
#' @examples
#' \dontrun{
#' parse.fname('results-1-simple.csv',
#'             'results-(\\d+)-(\\w+)\\.csv',
#'             c('ID', 'config'))
#' }
parse.fname <- function(fname, pattern, fields) {
  assert(length(fields) >= 1, 'Empty field list')
  m <- stringr::str_match(fname, pattern)
  assert(length(m) == length(fields) + 1, 'Wrong number of fields')
  assert(all(is.na(m)) == FALSE, 'Pattern did not match file name')
  return(setNames(as.list(m[2:length(m)]), fields))
}

#' Loads data from a CSV file
#' 
#' This function loads data from the given CSV file and it adds some extra
#' data coming from the fields in the file name. The number of capture groups
#' in the regular expression (pattern) must match the number of fields.
#' @param fname CSV file name.
#' @param pattern Regular expression used to extract the fields values.
#' @param fields Fields that uniquely identify the data from a CSV file.
#' @param custom.func Function for post-processing the data. Defaults to NULL.
#' @return A data.table object containing the data read from the CSV file.
#' @import data.table
#' @export
#' @examples
#' \dontrun{
#' load.data.file('results-1-simple.csv',
#'                'results-(\\d+)-(\\w+)\\.csv',
#'                c('ID', 'config'))
#' }
load.data.file <- function(fname, pattern, fields, custom.func = NULL) {
  print(sprintf('Reading %s', fname))
  dt <- data.table::data.table(read.csv(fname))
  info <- parse.fname(fname, pattern, fields)
  dt[, (fields) := info]

  if (is.null(custom.func)) dt
  else custom.func(dt)
}

#' Loads data from multiple CSV files and combines the data into a data.table
#' 
#' This function searches for CSV files matching a pattern in the given path
#' and combines all the data into a data.table object. The number of capture
#' groups in the regular expression (pattern) must match the number of fields.
#' @param path Path where to search for the CSV files.
#' @param pattern Regular expression used to search the CSV files and extract
#'     the fields values too.
#' @param fields Fields that uniquely identify the data from a CSV file.
#' @param local.func Custom function to be called after reading a single CSV
#'     file. Defaults to NULL.
#' @param global.func Custom function to be called after all the data tables
#'     have been merged into a single one. Defaults to NULL.
#' @return A data.table object containing the data read from the CSV files.
#' @export
#' @examples
#' \dontrun{
#' load.data('.', 'results-(\\d+)-(\\w+)\\.csv', c('ID', 'config'))
#' }
load.data <- function(path,
                      pattern,
                      fields,
                      local.func = NULL,
                      global.func = NULL) {
  assert(length(fields) >= 1, 'Empty field list')
  file.list <- .list.files(path, pattern)
  dt.list <- lapply(file.list,
                    function(fname) {
                      load.data.file(fname, pattern, fields, local.func)
                    })
  dt <- do.call(rbind, dt.list)

  if (is.null(global.func)) dt
  else global.func(dt)
}

