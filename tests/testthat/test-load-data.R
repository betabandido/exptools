library(stringr)
context("Load data")

test_that("Fields are correctly parsed in parse.fname", {
  expect_identical(
    parse.fname('test-1.csv', 'test-(\\d+)\\.csv', c('ID')),
    list('ID' = '1'))
  
  expect_identical(
    parse.fname('test-A-1.csv', 'test-(\\w+)-(\\d+)\\.csv', c('CFG', 'ID')),
    list('CFG' = 'A', 'ID' = '1'))

  expect_identical(
    parse.fname('results-simple/test-A-1.csv', 'results-(\\w+)/test-(\\w+)-(\\d+)\\.csv', c('METHOD', 'CFG', 'ID')),
    list('METHOD' = 'simple', 'CFG' = 'A', 'ID' = '1'))
})

test_that("Invalid parameters are detected in parse.fname", {
  expect_error(
    parse.fname('test.csv', 'test\\.csv', c()),
    'Empty field list')

  expect_error(
    parse.fname('test.csv', 'test\\.csv', c('ID')),
    'Wrong number of fields')

  expect_error(
    parse.fname('test.csv', 'test-(\\d+)\\.csv', c('ID')),
    'Pattern did not match file name')
})

test_that("load.data.file passes a minimal test", {
  test.data <- data.table(X = 1:5, Y = (1:5) ^ 2)
  fname <- tempfile(pattern = 'results-quad-', fileext = '.csv')
  write.csv(test.data, fname, row.names = F)

  dt <- load.data.file(fname, 'results-(\\w+)-.*\\.csv', c('METHOD'))
  expect_true(all(colnames(dt) == c('X', 'Y', 'METHOD')))
  expect_true(all(dt$METHOD == 'quad'))
  expect_true(all(dt$Y == dt$X ^ 2))

  dt <- load.data.file(fname, 'results-(\\w+)-.*\\.csv', c('METHOD'),
                       function(dt) { dt[, Y := 2 * Y]})
  expect_true(all(dt$Y == 2 * dt$X ^ 2))
})
