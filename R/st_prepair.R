#' Repair polygon geometries
#'
#' TODO
#'
#' @param x sf object.
#'
#' @return sf object.
#'
#' @export
st_prepair <- function(x, min_area = 0) UseMethod("st_prepair")

#' @export
st_prepair.sf <- function(x, min_area = 0) {
  # assert arguments are valid
  assertthat::assert_that(inherits(x, "sf"), assertthat::is.number(min_area),
                          assertthat::noNA(min_area))
  # repair geometries
  sf::st_geometry(x) <- st_prepair.sfc(sf::st_geometry(x))
  x
}

#' @export
st_prepair.sfc <- function(x, min_area = 0) {
  # assert arguments are valid
  assertthat::assert_that(inherits(x, "sfc"), assertthat::is.number(min_area),
                          assertthat::noNA(min_area))
  # store attributes
  x_crs <- sf::st_crs(x)
  x_prec <- sf::st_precision(x)
  # replace sliver geometries with empty geometries
  x_pl <- grepl("POLYGON", sf::st_geometry_type(x))
  x <- replace(x,
               which((as.numeric(sf::st_area(x)) < 1) & x_pl),
               list(sf::st_geometrycollection()))
  # check if any non-polygon objects detected
  if (!all(x_pl))
    warning("non-polygonal geometries will not be repaired", immediate. = TRUE)
  # convert MULTIPOLYGONS to POLYGONS
  x_pl <- grepl("POLYGON", sf::st_geometry_type(x))
  s <- sf::st_sf(id = which(x_pl), geometry = x[x_pl])
  st_crs(s) <- st_crs()
  suppressWarnings({s <- sf::st_cast(s, "POLYGON")})
  # find number of vertices in each polygon so that we can omit
  # polygons with four vertices when running prepair since it can't handle them
  nv <- vapply(s$geometry, function(x) nrow(x[[1]]), numeric(1))
  # clean POLYGONS
  s2 <- data.frame(id = s$id[nv > 4])
  s2$geometry = rcpp_prepair(sf::st_as_text(s$geometry[nv > 4]), min_area)
  s2 <- st_as_sf(s2, wkt = "geometry")
  # add in polygons with four vertices, note that we manually set
  # some default CRS to ensure that rbind works
  if (any(nv <= 4)) {
    st_crs(s2) <- st_crs("+init=epsg:4326")
    st_crs(s) <- st_crs("+init=epsg:4326")
    s2 <- rbind(s2, s[nv <= 4, ])
    s2 <- s2[order(s2$id), , drop = FALSE]
  }
  # dissolve polygons
  s2 <- lapply(split(s2$geometry, s2$id), do.call, what = sf::st_union)
  # merge dissolved polygons with original sfc object
  x <- replace(x$geometry, which(x_pl), s2)
  # return result
  x <- st_sfc(x)
  st_crs(x) <- x_crs
  st_precision(x) <- x_prec
  x
}
