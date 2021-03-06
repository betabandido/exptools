library(stringr)
context('Load data')

test_that('parse.fname fails with empty filename', {
  expect_error(
    parse.fname('', '.*', c('BAR')),
    'Empty filename'
  )
})

test_that('parse.fname fails with empty pattern', {
  expect_error(
    parse.fname('test.csv', '', c('BAR')),
    'Empty pattern'
  )
})

test_that('parse.fname fails with no fields', {
  expect_error(
    parse.fname('test.csv', '.*', c()),
    'Empty field list'
  )
})

test_that('parse.fname fails if fields do not match pattern', {
  expect_error(
    parse.fname('test.csv', 'test\\.csv', c('FOO')),
    'Wrong number of fields')
})

test_that('parse.fname fails if pattern does not match filename', {
  expect_error(
    parse.fname('test.csv', 'test-(\\d+)\\.csv', c('FOO')),
    'Pattern did not match file name')
})

test_that('parse.fname correctly parses fields', {
  expect_identical(
    parse.fname('foo-1.csv',
                'foo-(\\d+)\\.csv',
                c('FOO')),
    list('FOO' = '1'))

  expect_identical(
    parse.fname('test-foo-1.csv',
                'test-(\\w+)-(\\d+)\\.csv',
                c('FOO', 'NUM')),
    list('FOO' = 'foo', 'NUM' = '1'))

  expect_identical(
    parse.fname('results-foo/test-bar-1.csv',
                'results-(\\w+)/test-(\\w+)-(\\d+)\\.csv',
                c('FOO', 'BAR', 'NUM')),
    list('FOO' = 'foo', 'BAR' = 'bar', 'NUM' = '1'))
})

test_that('load.data.file fails if file does not exist', {
  expect_error(
    load.data.file('foobar-1', '.*-(\\d+)', c('NUM')),
    'File .* does not exist'
  )
})

test_that('load.data.file fails with no fields', {
  with_mock(
    `data.table::fread` = function(...) data.table::data.table(),
    expect_error(
      load.data.file('test.csv', '.*', c()),
      'Empty field list'
    )
  )
})

test_that('load.data.file parses field', {
  with_mock(
    `data.table::fread` = function(...)
        data.table::data.table(X = 1:5, Y = (1:5) ^ 2),
    dt <- load.data.file(
      'test-foo.csv',
      'test-(\\w+)\\.csv',
      c('FOO')),
    expect_true(all(colnames(dt) == c('X', 'Y', 'FOO'))),
    expect_true(all(dt$FOO == 'foo')),
    expect_true(all(dt$Y == dt$X ^ 2))
  )
})

test_that('load.data.file uses custom function', {
  with_mock(
    `data.table::fread` = function(...)
        data.table::data.table(X = 1:5, Y = (1:5) ^ 2),
    dt <- load.data.file(
      'test-foo.csv',
      'test-(\\w+)\\.csv',
      c('FOO'),
      function(dt) { dt[, Z := 2 * Y]}),
    expect_true(all(colnames(dt) == c('X', 'Y', 'FOO', 'Z'))),
    expect_true(all(dt$FOO == 'foo')),
    expect_true(all(dt$Y == dt$X ^ 2)),
    expect_true(all(dt$Z == 2 * dt$Y))
  )
})

test_that('load.data fails if no match is found', {
  with_mock(
    `exptools::.list.files` = function(...) c(character(0)),
    expect_error(
      load.data('.', '.*', c('FOO')),
      'No match was found'
    )
  )
})

test_that('load.data combines files', {
  dt.list <- list(
    data.table::data.table(X = 1:5, Y = 1 * (1:5) ^ 2),
    data.table::data.table(X = 1:5, Y = 2 * (1:5) ^ 2),
    data.table::data.table(X = 1:5, Y = 1 * (1:5) ^ 3),
    data.table::data.table(X = 1:5, Y = 2 * (1:5) ^ 3)
  )

  make.data.generator <- function() {
    idx <- 0
    gen <- function() {
      idx <<- idx + 1
      assert(idx <= length(dt.list))
      return(dt.list[[idx]])
    }
    return(gen)
  }

  data.generator <- make.data.generator()

  expected.dt <- do.call(rbind, dt.list)
  expected.dt[, FOO := c(rep('foo', 10), rep('bar', 10))]
  expected.dt[, NUM := c(rep('1', 5), rep('2', 5), rep('1', 5), rep('2', 5))]

  with_mock(
    `exptools::.list.files` = function(...)
      c('./res-foo/1.csv',
        './res-foo/2.csv',
        './res-bar/1.csv',
        './res-bar/2.csv'),
    `data.table::fread` = function(...) data.generator(),
    dt <- load.data(
      '.',
      './res-(\\w+)/(\\d+)\\.csv',
      c('FOO', 'NUM')),
    expect_identical(dt, expected.dt)
  )
})
