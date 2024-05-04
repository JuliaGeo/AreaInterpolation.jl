#=
# The `interpolate` function

This file defines the `interpolate` function's top and mid-level definitions, 
allowing the low level definitions to be 
=#
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
