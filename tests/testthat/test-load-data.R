library(stringr)
context("Load data")

test_that("Fields are correctly parsed", {
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
