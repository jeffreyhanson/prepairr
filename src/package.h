#ifndef PACKAGE_H
#define PACKAGE_H

/* Load header files, set plugins, load Rcpp namespace */
#include <ogr_api.h>
#include <ogr_geometry.h>
#include <ogrsf_frmts.h>

#include <progress.hpp>
#include <progress_bar.hpp>

#include "definitions.h"
#include "PolygonRepair.h"
#include "TriangleInfo.h"

// [[Rcpp::plugins(cpp11)]]
using namespace Rcpp;

#endif
