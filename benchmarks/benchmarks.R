# This file is taken from 
# primary package
library(areal)

# tidyverse packages
library(dplyr)

# spatial packages
library(sf)
library(tidycensus)
library(tigris)

# other packages
library(gridExtra)
library(microbenchmark)
library(testthat)

data(ar_stl_asthma, package = "areal")
data(ar_stl_race, package = "areal")
data(ar_stl_wards, package = "areal")
data(ar_stl_wardsClipped, package = "areal")
# Take the benchmark for the St. Louis polygons
res <- microbenchmark(
  aw_interpolate(ar_stl_wards, tid = WARD, source = ar_stl_race, sid = GEOID,
                 weight = "sum", output = "tibble", extensive = "TOTAL_E"),
  suppressWarnings(st_interpolate_aw(ar_stl_race["TOTAL_E"], ar_stl_wards, extensive = TRUE))
)
# Save the results of the benchmarking run
save(res, file = "benchmarks.RData")

# Unit: milliseconds
#                                                                                                                                          expr
#  aw_interpolate(ar_stl_wards, tid = WARD, source = ar_stl_race,      sid = GEOID, weight = "total", output = "tibble", extensive = "TOTAL_E")
#                                              suppressWarnings(st_interpolate_aw(ar_stl_race["TOTAL_E"], ar_stl_wards,      extensive = TRUE))
#       min       lq     mean   median      uq       max neval
#  68.34967 70.47232 73.24867 71.72536 74.1533 141.96041   100
#  63.22327 66.42303 68.14503 67.85898 69.4612  99.51569   100