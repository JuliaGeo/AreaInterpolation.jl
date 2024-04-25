# # Types

"""
    abstract type AbstractArealInterpolator

The abstract type for all areal interpolation methods.

## Interface
All `AbstractArealInterpolator`s must implement the following interface:
- `interpolate(interpolator::AbstractArealInterpolator, target::GI.AbstractPolygon, sources, values::Vector{Vector}, source_rtree)`
This interface is not set in stone and can be changed!

TODOS:
    - extensive vs intensive variables (currently we act as though variables are intensive)
    - weight methods (sum vs total) - just pass any arbitrary accumulator
"""
abstract type AbstractArealInterpolator end

# Define the API as well as the toplevel conversion methods
function interpolate(interpolator::AbstractArealInterpolator, target, sources; kwargs...)
    return interpolate(interpolator, GI.trait(target), GI.trait(sources), target, sources; kwargs...)
end

function interpolate(interpolator::AbstractArealInterpolator, ::Union{GI.PolygonTrait, GI.MultiPolygonTrait}, ft::Union{GI.FeatureCollectionTrait, Nothing}, target, sources; features = nothing, kwargs...)
    source_geometries, source_values = decompose_to_geoms_and_values(sources; features)
    source_rtree = SortTileRecursiveTree.STRtree(source_geometries)
    # It's the FC -> FC level that has to deal with reconstructing features, so we don't do that here.
    return interpolate(interpolator, target, source_geometries, source_values, GO.area.(source_geometries), source_rtree)
end

function interpolate(interpolator::AbstractArealInterpolator, TargetTrait::Union{GI.FeatureCollectionTrait, Nothing}, SourceTrait::Union{GI.FeatureCollectionTrait, Nothing}, target, sources; features = nothing, kwargs...)
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
        interpolate(interpolator, polygon, source_geometries, source_values, source_areas, source_rtree)
    end
    interpolated_feature_values = map(_interp_poly, target_geometries) 
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

