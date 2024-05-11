#=
# Types

This file defines abstract types and some interface methods, as well as custom error types used in AreaInterpolation.
=#
"""
    abstract type AbstractInterpolationMethod

The abstract type for all areal interpolation methods.

## Interface
All `AbstractArealInterpolator`s must implement the following interface:
- `interpolate(interpolator::AbstractInterpolationMethod, target::GI.AbstractPolygon, sources, values::Vector{Vector}, source_rtree)`
This interface is not set in stone and can be changed!

TODOS:
    - extensive vs intensive variables (currently we act as though variables are intensive)
    - weight methods (sum vs total) - just pass any arbitrary accumulator
"""
abstract type AbstractInterpolationMethod end
# The `interpolate` method is defined in `interpolate.jl`, since it includes
# a lot of logic for data handling as well as CRS checks, etc.


"""
    Direct()

A simple direct method for areal interpolation.  

Takes the area-weighted mean of all source polygons' features, 
weighted by their areas of intersection with the target polygon.

This method does not allocate a Raster, but it does perform polygon intersection tests.
"""
struct Direct <: AbstractInterpolationMethod end
# Direct is pretty straightforward - but it could be renamed.
"""
    Pycnophylactic(cellsize; relaxation, maxiters, tol)

A pycnophylactic method for areal interpolation.

Pycnophylactic interpolation (Tobler, 1979) interpolates the source zone attribute 
to the target zones in a way that avoids sharp discontinuities between neighbouring 
target zones.  It assumes that no sharp boundaries exist in the distribution of the 
allocated data, which may not be the case, for example, when target zones are divided 
by linear features (rivers, railways, roads) or are adjacent to waterbodies. 

However, it generates intuitively elegant allocations for many urban case studies with 
many applications (Kounadi, Ristea, Leitner, & Langford, 2018; Comber, Proctor, & Anthony, 2008).

This description was taken in part from [the GIS&T Body of Knowledge](https://gistbok.ucgis.org/bok-topics/areal-interpolation).

## Fields
$(FIELDS)

## Differences from other implementations

`tobler` in Python uses the equivalent of `Stencils.Kernel(Stencils.Cross(1, 2), [0.25, 0.25, 0, 0.25, 0.25])`.  
This implementation allows arbitrary kernels, so the user can choose the kind of smoothing and kernel window 
based on their desires.

"""
struct Pycnophylactic <: AbstractInterpolationMethod 
    "The cell size of the raster to be interpolated, in units of the CRS of the input polygons (can be degrees or meters).  **Required argument!**"
    cellsize::Float64
    "The kernel with which to smooth the raster.  Defaults to a 2-D Moore window of size 1, with value 0.5."
    kernel::Stencils.Stencil
    "The relaxation factor.  Defaults to `0.2`."
    relaxation::Float64
    "The maximum number of iterations.  Defaults to `300`."
    maxiters::Int
    "The error tolerance at which convergence is achieved.  Defaults to `10e-3`."
    tol::Float64
end
# This one-line constructor defines allowed keyword arguments.
Pycnophylactic(
    cellsize; 
    kernel, 
    relaxation = 0.2, 
    maxiters = 300, 
    tol = 10e-3
) = Pycnophylactic(cellsize, kernel, relaxation, maxiters, tol)
"""
    Pycno(...)

Alias for [`Pycnophylactic`](@ref).
"""
const Pycno = Pycnophylactic # who exactly is going to type this thing?


"""
    Dasymetric(mask::Raster)

Dasymetric interpolation uses a mask to weight the influence of each polygon.  

Depending on the choice of mask, like land-use data, this can prove to be a 
more accurate interpolation than the direct or pycnophylactic methods.
"""
struct Dasymetric <: AbstractInterpolationMethod 
    mask::Rasters.Raster
end
# Potential examples: using Facebook's population density data, or land-use data, or even nightlights.  That would actually be cool...

# TODO: street-weighted interpolation (again kind of like dasymetric), but with e.g. OpenStreetMap integration.

# ## Custom errors
struct CRSMismatchError <: Exception
    target_crs
    source_crs
end

function Base.showerror(io::IO, err::CRSMismatchError)
    print(
        io, 
        """
        CRSMismatchError: The CRS of the target and source geometries do not match.
        Target CRS: """
    )
    display(Base.TextDisplay(io), MIME"text/plain"(), err.target_crs)
    print(io, "Source CRS: ")
    display(Base.TextDisplay(io), MIME"text/plain"(), err.source_crs)
end

