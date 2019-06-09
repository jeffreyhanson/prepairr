#include "package.h"

// [[Rcpp::export]]
Rcpp::CharacterVector rcpp_prepair(Rcpp::CharacterVector x,
                                   double min_area = 0.0) {
  // Initialization
  const std::size_t n = x.size();
  const unsigned int buffer_size = 100000000;
  Rcpp::CharacterVector out(n);
  std::string input_wkt;
  std::string output_wkt;

  // Main processing
  for (std::size_t i = 0; i < n; ++i) {
    /// init
    PolygonRepair prepair;
    OGRGeometry *raw_geometry;
    OGRMultiPolygon *repaired_geometry;
    char *input_wkt2 = (char *)malloc(buffer_size * sizeof(char));
    char *output_wkt2;
    /// convert wkt to OGRGeometry
    input_wkt = Rcpp::as<std::string>(x[i]);
    strcpy(input_wkt2, input_wkt.c_str());
    OGRErr err = OGRGeometryFactory::createFromWkt(&input_wkt2, NULL,
                                                   &raw_geometry);
    /// scan for problems
    if (err != OGRERR_NONE)
      Rcpp::stop("invalid input.");
    // clean polygon
    repaired_geometry = prepair.repairOddEven(raw_geometry, false);
    /// remove small polygons if specified
    if (min_area > 1.0e-10)
      prepair.removeSmallPolygons(repaired_geometry, min_area);
    /// convert object to WKT representation
    repaired_geometry->exportToWkt(&output_wkt2);
    output_wkt.assign(output_wkt2);
    out[i] = output_wkt;
    /// cleanup
    OGRGeometryFactory::destroyGeometry(raw_geometry);
    OGRGeometryFactory::destroyGeometry(repaired_geometry);
  }

  // Exports
  return out;
}
