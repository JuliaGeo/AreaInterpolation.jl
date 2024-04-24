module ArealInterpolation

# Multiple methods.  We start with the regular method, i.e., simple area interpolation without any redeeming features.
# Then, we'll branch out into pycnophylactic interpolation, which is still free of external information.

# Following this, we implement dasymetric interpolation.

using GeoInterface, GeometryOps
import GeometryOps as GO, GeoInterface as GI

import Rasters, Stencils

# ## Types

"""
    abstract type AbstractArealInterpolator

The abstract type for all areal interpolation methods.

## Interface
All `AbstractArealInterpolator`s must implement the following interface:
- `interpolate(interpolator::AbstractArealInterpolator, target::GI.AbstractPolygon, sources::AbstractVector{Union{PolygonTrait, MultiPolygonTrait}}, values::AbstractVector)`
- `interpolate(interpolator::AbstractArealInterpolator, target::GI.AbstractGeometry, source::GI.AbstractGeometry, weights::AbstractVector)`
"""
abstract type AbstractArealInterpolator end

"""
    Direct()

A simple direct method for areal interpolation.  

Takes the area-weighted mean of all source polygons' features, 
weighted by their areas of intersection with the target polygon.

This method does not allocate a Raster, but it does perform polygon intersection tests.
"""
struct Direct <: AbstractArealInterpolator end

"""
    Pycnophylactic()

A pycnophylactic method for areal interpolation.

Pycnophylactic interpolation (Tobler, 1979) interpolates the source zone attribute 
to the target zones in a way that avoids sharp discontinuities between neighbouring 
target zones.  It assumes that no sharp boundaries exist in the distribution of the 
allocated data, which may not be the case, for example, when target zones are divided 
by linear features (rivers, railways, roads) or are adjacent to waterbodies. 

However, it generates intuitively elegant allocations for many urban case studies with 
many applications (Kounadi, Ristea, Leitner, & Langford, 2018; Comber, Proctor, & Anthony, 2008).

This description was taken in part from [the GIS&T Body of Knowledge](https://gistbok.ucgis.org/bok-topics/areal-interpolation).
"""
struct Pycnophylactic <: AbstractArealInterpolator end
const Pycno = Pycnophylactic # who exactly is going to type this thing?

"""
    Dasymetric(mask::Raster)

Dasymetric interpolation uses a mask to weight the influence of each polygon.  

Depending on the choice of mask, like land-use data, this can prove to be a 
more accurate interpolation than the direct or pycnophylactic methods.
"""
struct Dasymetric <: AbstractArealInterpolator 
    mask::Rasters.Raster
end

end
