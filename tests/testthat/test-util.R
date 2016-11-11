context('Util')

test_that('false assert throws an error', {
  msg <- '1 is not equal to 2'
  expect_error(
    assert(1 == 2, msg),
    msg)
})

test_that('true assert does not throw an error', {
  expect_silent(assert(1 == 1, '1 must be equal to 1'))
})

test_that('curry works with function accepting no arguments', {
  expect_identical(
    curry(function() { return('foo') })(),
    'foo'
  )
})

test_that('curry stores argument', {
  expect_identical(
    curry(function(x) { return(x); }, x = 'foo')(),
    'foo'
  )
})

test_that('curry forwards argument', {
  expect_identical(
    curry(function(x) { return(x); })('foo'),
    'foo'
  )
})

test_that('curry stores and forwards arguments', {
  expect_identical(
    curry(function(x, y) { return(paste(x, y)); }, x = 'foo')('bar'),
    'foo bar'
  )
})

test_that('list.files fails if path is empty', {
  expect_error(
    .list.files('', '.*\\.csv'),
    'path must be a non-empty string'
  )
})

test_that('list.files fails if pattern is empty', {
  expect_error(
    .list.files('.', ''),
    'pattern must be a non-empty string'
  )
})

.expect_empty_chr_vector <- function(x) {
  expect_true(is.character(x))
  expect_length(x, 0)
}

test_that('list.files returns empty vector if no matching', {
  with_mock(
    `base::list.files` = function(...) c(''),
    .expect_empty_chr_vector(.list.files('.', './\\w+/\\d+\\.csv'))
  )
})

test_that('list.files returns empty vector for wrong paths', {
  .expect_empty_chr_vector(.list.files('/foo', 'bar\\.csv'))
  .expect_empty_chr_vector(.list.files('/foo', '/'))
  .expect_empty_chr_vector(.list.files('/foo', '//'))
})

test_that('list.files filters non-matching results', {
  with_mock(
    `base::list.files` = function(...)
      c('./res-foo/1.csv',
        './res-bar/1.csv',
        './res-bar/other.csv',
        './other/other.csv'),
    res <- .list.files('.', './res-\\w+/\\d+\\.csv'),
    expect_identical(res,
                     c('./res-foo/1.csv',
                       './res-bar/1.csv'))
  )
})
