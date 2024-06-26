# Interpolation methods

`AreaInterpolation.jl` provides several methods for interpolating data across polygons.

## Direct method



## Pycnophylactic method

The whole idea is rasterizing a set of polygons with some associated value, smoothing it, then summing the values within your other set of target polygons.  The difference between this and a regular Gaussian filter is that at each iteration, the value in each source polygon is preserved.  This is to say that if one were to aggregate the values back to the source right after the smoothing, then one would recieve the same values as output as they would 
during input.


## Dasymetric method

### Raster masks
Raster masks are supported.
### Vector masks
Vector masks (like building footprints) are not yet supported.  It's trivial to do this by two interpolations, though -- first interpolate the source values to the intermediate geometries, then interpolate the intermediate geometries to the target geometries.

## Weighted-pycnophylactic method

