#' Repair geometry using prepair
#'
#' Repair invalid geometry using constrained triangulation via the prepair
#' software library (Ledoux, Arroyo Ohori & Meijers, 2014,
#' \url{https://github.com/tudelft3d/prepair}).
#'
#' @param x \code{\link[sf]{sf}} object.
#'
#' @param min_area \code{numeric} minimum area permitted. Polygons with an
#'   area below this threshold are treated as slivers and omitted from analysis.
#'   Defaults to 0.00001.
#'
#' @details Note that any non-polygonal geometries (e.g. point or line data) are
#'   not subjected to the data cleaning process.
#'
#' @return \code{\link[sf]{sf}} object with repaired geometry.
#'
#' @references
#' Ledoux H, Arroyo Ohori K, and Meijers M (2014) A triangulation-based
#' approach to automatically repair GIS polygons. Computers & Geosciences
#' 66:121--131
#'
#' @seealso \code{\link[lwgeom]{st_make_valid}},
#'   \code{\link[sf]{st_is_valid}}.
#'
#' @examples
#' # create sf object with invalid geometry
#' x <- st_sfc(st_polygon(list(rbind(c(0, 0), c(0.5, 0), c(0.5, 0.5),
#'                                   c(0.5, 0), c(1, 0), c(1, 1), c(0, 1),
#'                                   c(0, 0)))))
#'
#' # verify that geometry is invalid
#' suppressWarnings(st_is_valid(x))
#'
#' # fix geometry using prepair
#' y <- st_prepair(x)
#'
#' # verify that repaired geometry is valid
#' st_is_valid(y)
#'
#' # plot the original and repaired geometries
#' par(mfrow = c(1, 2))
#' plot(st_geometry(x), main = "invalid geometry")
#' plot(st_geometry(y), main = "repaired geometry")
#'
#' @export
st_prepair <- function(x, min_area = 1e-5) UseMethod("st_prepair")

#' @export
st_prepair.sf <- function(x, min_area = 1e-5) {
  # assert arguments are valid
  assertthat::assert_that(inherits(x, "sf"), assertthat::is.number(min_area),
                          assertthat::noNA(min_area))
  # repair geometries
  sf::st_geometry(x) <- st_prepair.sfc(sf::st_geometry(x))
  x
}

#' @export
st_prepair.sfc <- function(x, min_area = 1e-5) {
  # assert arguments are valid
  assertthat::assert_that(inherits(x, "sfc"), assertthat::is.number(min_area),
                          assertthat::noNA(min_area))
  # store attributes
  x_crs <- sf::st_crs(x)
  x_prec <- sf::st_precision(x)
  # replace sliver geometries with empty geometries
  x_pl <- grepl("POLYGON", sf::st_geometry_type(x))
  x <- replace(x, which((as.numeric(sf::st_area(x)) < 1) & x_pl),
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
  nv_gte4 <- nv > 4
  # clean polygons
  s2 <- data.frame(id = s$id[nv_gte4])
  s2$geometry <- rcpp_prepair(sf::st_as_text(s$geometry[nv_gte4]), min_area)
  s2 <- st_as_sf(s2, wkt = "geometry")
  # add in polygons with four vertices, note that we manually set
  # some default CRS to ensure that rbind works
  if (any(nv_gte4)) {
    st_crs(s2) <- st_crs("+init=epsg:4326")
    st_crs(s) <- st_crs("+init=epsg:4326")
    s2 <- rbind(s2, s[nv_gte4, ])
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
