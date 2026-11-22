# Tests for calc_mean

test_that("calc_mean returns the correct mean", {
  expect_equal(calc_mean(c(1, 2, 3)), 2)
  expect_equal(calc_mean(c(10)), 10)
  expect_equal(calc_mean(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)), 4.3)
})

test_that("calc_mean ignores NA values", {
  expect_equal(calc_mean(c(1, NA, 3)), 2)
})

test_that("calc_mean errors on bad input", {
  expect_error(calc_mean(numeric(0)), "Vector is empty.")
  expect_error(calc_mean(c(NA_real_, NA_real_)), "Vector contains only NA values.")
  expect_error(calc_mean(c("a", "b")), "Vector contains non-numeric values.")
})

# Tests for calc_median

test_that("calc_median handles odd and even length vectors", {
  expect_equal(calc_median(c(5, 1, 3)), 3)
  expect_equal(calc_median(c(4, 1, 3, 2)), 2.5)
  expect_equal(calc_median(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)), 4.5)
})

test_that("calc_median ignores NA values", {
  expect_equal(calc_median(c(1, NA, 7, 3)), 3)
})

test_that("calc_median errors on bad input", {
  expect_error(calc_median(numeric(0)), "Vector is empty.")
  expect_error(calc_median(c("a", "b")), "Vector contains non-numeric values.")
})

# Tests for calc_mode

test_that("calc_mode returns single and multiple modes", {
  expect_equal(calc_mode(c(1, 2, 2, 3)), 2)
  expect_equal(calc_mode(c(1, 1, 2, 2, 3)), c(1, 2))
  expect_equal(calc_mode(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)), 5)
})

test_that("calc_mode handles single values and NAs", {
  expect_equal(calc_mode(c(5)), 5)
  expect_equal(calc_mode(c(1, NA, 2, 2)), 2)
})

test_that("calc_mode errors when there is no mode", {
  expect_error(calc_mode(c(1, 2, 3)), "Vector has no mode.")
})

test_that("calc_mode errors on bad input", {
  expect_error(calc_mode(numeric(0)), "Vector is empty.")
  expect_error(calc_mode(c(NA_real_, NA_real_)), "Vector contains only NA values.")
  expect_error(calc_mode(c("a", "b")), "Vector contains non-numeric values.")
})

# Tests for calc_q1

test_that("calc_q1 returns the first quartile", {
  expect_equal(calc_q1(c(1, 2, 3, 4, 5)), 2)
  expect_equal(calc_q1(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)), 2.25)
})

test_that("calc_q1 returns an unnamed value and ignores NAs", {
  expect_null(names(calc_q1(c(1, 2, 3, 4, 5))))
  expect_equal(calc_q1(c(1, 2, NA, 3, 4, 5)), 2)
})

test_that("calc_q1 errors on bad input", {
  expect_error(calc_q1(numeric(0)), "Vector is empty.")
  expect_error(calc_q1(c("a", "b")), "Vector contains non-numeric values.")
})

# Tests for calc_q3

test_that("calc_q3 returns the third quartile", {
  expect_equal(calc_q3(c(1, 2, 3, 4, 5)), 4)
  expect_equal(calc_q3(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)), 5)
})

test_that("calc_q3 returns an unnamed value and ignores NAs", {
  expect_null(names(calc_q3(c(1, 2, 3, 4, 5))))
  expect_equal(calc_q3(c(1, 2, NA, 3, 4, 5)), 4)
})

test_that("calc_q3 errors on bad input", {
  expect_error(calc_q3(numeric(0)), "Vector is empty.")
  expect_error(calc_q3(c("a", "b")), "Vector contains non-numeric values.")
})

# Tests for calc_iqr

test_that("calc_iqr returns Q3 - Q1", {
  expect_equal(calc_iqr(c(1, 2, 3, 4, 5)), 2)
  expect_equal(calc_iqr(c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)), 2.75)
})

test_that("calc_iqr is never negative", {
  expect_gte(calc_iqr(c(10, 3, 8, 1, 6)), 0)
})

test_that("calc_iqr errors on bad input", {
  expect_error(calc_iqr(numeric(0)), "Vector is empty.")
  expect_error(calc_iqr(c("a", "b")), "Vector contains non-numeric values.")
})
