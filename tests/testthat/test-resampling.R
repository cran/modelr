d <- head(mtcars, 30)
d$row <- 1:30

test_that("Can perform cross validation", {
  cross <- crossv_kfold(d, k = 5)

  expect_equal(nrow(cross), 5)

  trains <- map(cross$train, as.data.frame)
  expect_true(all(purrr::map_dbl(trains, nrow) == 24))

  tests <- map(cross$test, as.data.frame)
  expect_true(all(purrr::map_dbl(tests, nrow) == 6))

  overlaps <- purrr::map2(purrr::map(trains, "row"), purrr::map(tests, "row"), intersect)
  expect_true(all(lengths(overlaps) == 0))
})

test_that("Can perform leave-one-out cross validation", {
  cross <- crossv_loo(d)

  expect_equal(nrow(cross), 30)

  trains <- map(cross$train, as.data.frame)
  expect_true(all(purrr::map_dbl(trains, nrow) == 29))

  tests <- map(cross$test, as.data.frame)
  expect_true(all(purrr::map_dbl(tests, nrow) == 1))

  overlaps <- purrr::map2(purrr::map(trains, "row"), purrr::map(tests, "row"), intersect)
  expect_true(all(lengths(overlaps) == 0))

  expect_true(cross[nrow(cross),]$.id==nrow(cross))
  expect_true(cross[1,]$.id==1)
})



test_that("Can perform bootstrapping", {
  boot <- mtcars %>%
    bootstrap(5)

  expect_equal(nrow(boot), 5)

  for (b in boot$strap) {
    bd <- as.data.frame(b)
    expect_equal(nrow(bd), nrow(mtcars))
    expect_true(all(bd$mpg %in% mtcars$mpg))
    expect_false(all(bd$mpg == mtcars$mpg))
  }
})


test_that("Can perform permutation", {
  perm <- mtcars %>%
    permute(5, mpg)

  expect_equal(nrow(perm), 5)

  for (p in perm$perm) {
    pd <- as.data.frame(p)
    expect_equal(mtcars$cyl, pd$cyl)
    expect_equal(mtcars$hp, pd$hp)
    expect_equal(sort(mtcars$mpg), sort(pd$mpg))
    # chance of permutation being the same is basically nil
    expect_false(all(mtcars$mpg == pd$mpg))
  }
})

test_that("appropriate args are supplied to resample_*()", {
  expect_error(resample("mtcars", 1:10), "data frame")
  expect_error(resample(mtcars, 10), "integer vector")
  expect_error(
    resample_permutation(mtcars,  c("mpg", "cyl"), idx = 2),
    "same length"
  )
  expect_error(
    resample_permutation("mtcars",  c("mpg", "cyl"), idx = 1:32),
    "data frame"
  )
  expect_error(
    resample_permutation(mtcars,  c("mpg", "iris"), idx = 1:32),
    "vector"
  )
})
