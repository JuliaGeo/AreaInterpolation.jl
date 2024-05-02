```@meta
CurrentModule = AreaInterpolation
```

# AreaInterpolation

AreaInterpolation.jl is a package that enables interpolation between collections of areas (usually polygons or multipolygons) associated with some data. 

Several different methods are offered here:
- `Direct()`
- `Pycnophylactic(cellsize::Float64)`
- `Dasymetric(raster_mask::Raster)`

and others, see the [Methods](@ref) section for more details.

