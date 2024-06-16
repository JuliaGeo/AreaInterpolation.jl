# AreaInterpolation

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaGeo.github.io/AreaInterpolation.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaGeo.github.io/AreaInterpolation.jl/dev/)
[![Build Status](https://github.com/JuliaGeo/AreaInterpolation.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaGeo/AreaInterpolation.jl/actions/workflows/CI.yml?query=branch%3Amain)

AreaInterpolation.jl is a package to perform "areal interpolation", that is, interpolating values associated with one set of polygons, to another set of polygons that overlap the first set [^GISTBOK].

Similar implementations in other languages can be found in [^areal] (R), [^sf] (R), and [^tobler] (Python).

## Quick start

The main entry point is the `AreaInterpolation.interpolate([alg], source, dest; extensive = (:col_a, :col_b), intensive = (:col1, :col2))`.

## Performance
AreaInterpolation.jl offers seamless multithreading support, and integrates with the rest of the Julia ecosystem as well!
![download-13](https://github.com/JuliaGeo/AreaInterpolation.jl/assets/32143268/bbc8b36e-f7a3-491d-afd2-045101d334d3)


References:

[^GISTBOK]: [GISTBOK Areal Interpolation chapter](https://gistbok.ucgis.org/bok-topics/areal-interpolation)
[^areal]: https://github.com/chris-prener/areal
[^sf]: Area-weighted interpolation also exists in R's `sf` package, (see the [sf documentation](https://r-spatial.github.io/sf/reference/interpolate_aw.html))
[^tobler-tutorial]: https://dges.carleton.ca/CUOSGwiki/index.php/Areal_Interpolation_in_Python_Using_Tobler
[^tobler]: Tobler, a Python package in the PySAL suite

