
<!--- README.md is generated from README.Rmd. Please edit that file -->
prepairr: Interface to prepair
------------------------------

[![lifecycle](https://img.shields.io/badge/Lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental) [![Travis Build Status](https://img.shields.io/travis/jeffreyhanson/prepairr/master.svg?label=Linux%20%26%20Mac%20OSX)](https://travis-ci.org/jeffreyhanson/prepairr) [![AppVeyor Build Status](https://img.shields.io/appveyor/ci/jeffreyhanson/prepairr/master.svg?label=Windows)](https://ci.appveyor.com/project/jeffreyhanson/prepairr) [![Coverage Status](https://codecov.io/github/jeffreyhanson/prepairr/coverage.svg?branch=master)](https://codecov.io/github/jeffreyhanson/prepairr?branch=master)

### Overview

The *prepairr R* package provides an interface to the *prepair* tool for repairing invalid polygon geometries. This project was developed as an experiment to benchmark the performance of the *prepair* tool for repairing invalid geometries in large spatial datasets. Unfortunately, this package is actually **slower** than standard geometry cleaning tools (such as [`lwgeom::st_make_valid`](https://r-spatial.github.io/lwgeom/reference/valid.html). As a consequence, this package is unlikely to receive further development.

### Installation

The developmental version of the *prepairr R* package can be installed using the following R code. Please note that this package will only work on Unix systems and requires the [*sf R*](https://github.com/r-spatial/sf) package which requires additional software to be installed. If you encounter problems installing the *prepairr R* package, please consult the installation instructions for the [*sf R*](https://github.com/r-spatial/sf) package.

``` r
if (!require(remotes))
  remotes::install_github("jeffreyhanson/prepairr")
```

### Usage

TODO.

### Citation

This is an experimental package. You should not be citing this package because you should not be using it for any serious work.
