context("st_prepair")

test_that("repairs geometry (sfc)", {
  # create data
  x <- st_sfc(
    st_polygon(list(rbind(c(0, 0), c(0.5, 0), c(0.5, 0.5), c(0.5, 0), c(1, 0),
                          c(1, 1), c(0, 1), c(0, 0)))),
    st_polygon(list(matrix(c(0, 0, 10, 0, 10, 10, 0, 10, 0, 0), ncol = 2,
                           byrow = TRUE),
                    matrix(c(1, 1, 1, 2, 2, 2, 2, 1, 1, 1), ncol = 2,
                           byrow = TRUE),
                    matrix(c(5, 5 ,5, 6, 6, 6, 6, 5, 5, 5), ncol = 2,
                           byrow = TRUE))))
  st_crs(x) <- 3857
  # repair geometry
  y <- st_prepair(x)
  y2 <- lwgeom::st_make_valid(y)
  # run tests
  expect_equal(suppressWarnings(st_is_valid(x)), c(FALSE, TRUE))
  expect_is(y, "sfc")
  expect_identical(st_crs(y)$epsg, 3857L)
  expect_equal(st_is_valid(y), c(TRUE, TRUE))
  expect_equivalent(y, y2)
  expect_is(attr(y, "prepair_time"), "numeric")
})

test_that("repairs geometry (sf)", {
  # create data
  x <- st_sfc(
    st_polygon(list(rbind(c(0, 0), c(0.5, 0), c(0.5, 0.5), c(0.5, 0), c(1, 0),
                          c(1, 1), c(0, 1), c(0, 0)))),
    st_polygon(list(matrix(c(0, 0, 10, 0, 10, 10, 0, 10, 0, 0), ncol = 2,
                           byrow = TRUE),
                    matrix(c(1, 1, 1, 2, 2, 2, 2, 1, 1, 1), ncol = 2,
                           byrow = TRUE),
                    matrix(c(5, 5 ,5, 6, 6, 6, 6, 5, 5, 5), ncol = 2,
                           byrow = TRUE))))
  x <- st_sf(x, data.frame(id = c(1, 2)))
  st_crs(x) <- 3857
  # repair geometry
  y <- st_prepair(x)
  y2 <- lwgeom::st_make_valid(y)
  # run tests
  expect_equal(suppressWarnings(st_is_valid(x)), c(FALSE, TRUE))
  expect_is(y, "sf")
  expect_identical(st_crs(y)$epsg, 3857L)
  expect_equal(st_is_valid(y), c(TRUE, TRUE))
  expect_equivalent(y, y2)
  expect_is(attr(y, "prepair_time"), "numeric")
})

test_that("non-polygonal geometries", {
  # create data
  x <- st_sfc(
    st_polygon(list(rbind(c(0, 0), c(0.5, 0), c(0.5, 0.5), c(0.5, 0), c(1, 0),
                          c(1, 1), c(0, 1), c(0, 0)))),
    st_point(c(1, 2)),
    st_multipoint(matrix(1:10, ncol = 2)),
    st_linestring(matrix(1:10, ncol = 2)),
    st_polygon(list(matrix(c(0, 0, 10, 0, 10, 10, 0, 10, 0, 0), ncol = 2,
                           byrow = TRUE),
                    matrix(c(1, 1, 1, 2, 2, 2, 2, 1, 1, 1), ncol = 2,
                           byrow = TRUE),
                    matrix(c(5, 5 ,5, 6, 6, 6, 6, 5, 5, 5), ncol = 2,
                           byrow = TRUE))))
  x <- st_sf(x, data.frame(id = seq_len(5)))
  st_crs(x) <- 3857
  # repair geometry
  expect_warning(y <- st_prepair(x))
  y2 <- lwgeom::st_make_valid(y)
  # run tests
  expect_equal(suppressWarnings(st_is_valid(x)), c(FALSE, rep(TRUE, 4)))
  expect_is(y, "sf")
  expect_identical(st_crs(y)$epsg, 3857L)
  expect_equal(st_is_valid(y), rep(TRUE, 5))
  expect_equivalent(y, y2)
  expect_is(attr(y, "prepair_time"), "numeric")
})
