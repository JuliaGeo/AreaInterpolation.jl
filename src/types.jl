# # Types

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

# Define the API as well as the toplevel conversion methods
function interpolate(interpolator::AbstractInterpolationMethod, target, sources; kwargs...)
    return interpolate(interpolator, GI.trait(target), GI.trait(sources), target, sources; kwargs...)
end
# Address the possibility that the target is a single geometry.  In this case, we return weights.  Should we return a Feature, though?
function interpolate(interpolator::AbstractInterpolationMethod, ::Union{GI.PolygonTrait, GI.MultiPolygonTrait}, ft::Union{GI.FeatureCollectionTrait, Nothing}, target, sources; features = nothing, kwargs...)
    source_geometries, source_values = decompose_to_geoms_and_values(sources; features)
    source_rtree = SortTileRecursiveTree.STRtree(source_geometries)
    # It's the FC -> FC level that has to deal with reconstructing features, so we don't do that here.
    return interpolate(interpolator, target, source_geometries, source_values, GO.area.(source_geometries), source_rtree; kwargs...)
end
# An algorithm which benefits from batching, or has a single processing step for the whole `source` collection,
# should override the version of `interpolate` that this calls.  
function interpolate(interpolator::AbstractInterpolationMethod, TargetTrait::Union{GI.FeatureCollectionTrait, Nothing}, SourceTrait::Union{GI.FeatureCollectionTrait, Nothing}, target, sources; features = nothing, threaded = true, kwargs...)
    # First, we extract the geometry and values from the source FeatureCollection
    source_geometries, source_values = decompose_to_geoms_and_values(sources; features)
    # Then, we also extract the geometries from the target FeatureCollection.  In this case,
    # we explicitly request all features, so that we can reconstruct the featurecollection later.
    target_geometries, target_values = decompose_to_geoms_and_values(target; features = setdiff(Tables.columnnames(target), GI.geometrycolumns(target)))
    # We build an STRtree for the source geometries
    source_rtree = SortTileRecursiveTree.STRtree(source_geometries)
    # Finally, we interpolate the polygons one by one.  This is done by passing them to the "kernel"
    # which is defined per interpolator.
    source_areas = GO.area.(source_geometries)
    function _interp_poly(polygon)
        interpolate(interpolator, polygon, source_geometries, source_values, source_areas, source_rtree; kwargs...)
    end
    interpolated_feature_values = if threaded
        OhMyThreads.tmap(_interp_poly, target_geometries)
    else
        map(_interp_poly, target_geometries) 
    end
    # The result of `map` above is a canonical row table form, being a Vector of NamedTuples.
    # We can convert it directly into a column table, i.e., a NamedTuple of Vectors, using Tables.
    new_feature_columns = Tables.columntable(interpolated_feature_values)
    # We create the final "column table", a NamedTuple of Vectors, by merging the target geometries
    # with the target values and the new feature columns.
    final_namedtuple = merge(
        NamedTuple{(first(GI.geometrycolumns(target)),)}((target_geometries,)),
        target_values,
        new_feature_columns
    )
    # Finally, we reconstruct and return -- currently as a DataFrame, but in the future
    # we should reconstruct based on the type of `target`.  GeometryOps can help there.
    # For Tables, we _could_ use `Tables.materializer`, but should check - if materializer
    # returns `Tables.columntable`, then we substitute that for `DataFrame(x; copycols = false)`.
    return DataFrames.DataFrame(final_namedtuple)
end

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

"""
struct Pycnophylactic <: AbstractInterpolationMethod 
    "The cellsize of the interpolated raster, in units of the CRS of the input polygons (can be degrees or meters).  **Required argument!**"
    cellsize::Float64
    "The relaxation factor.  Defaults to `0.2`."
    relaxation::Float64
    "The maximum number of iterations.  Defaults to `1000`."
    maxiters::Int
    "The tolerance.  Defaults to `10e-3`."
    tol::Float64
end
Pycnophylactic(cellsize; relaxation = 0.2, maxiters = 1000, tol = 10e-3) = Pycnophylactic(cellsize, relaxation, maxiters, tol)
const Pycno = Pycnophylactic # who exactly is going to type this thing?
# Pycno should abstract the "weighting" part of the algorithm to a function, so people can inspect the interpolated raster.

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

