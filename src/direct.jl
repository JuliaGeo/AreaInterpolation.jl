#=
# Direct interpolation

This file contains the implementation for the `Direct()` method.

=#
function interpolate(::Direct, polygon, sources::AbstractVector, values::NamedTuple, source_areas, source_rtree; kwargs...) # should be 2 params `intensive` and `extensive` as well...
    # First, query the spatial index for `source` for the polygons that may intersect our polygon.
    # WARNING: whichever spatial index you use must be thread-safe if using this in a multithreaded context!
    likely_polygon_indices = SortTileRecursiveTree.query(source_rtree, polygon) # TODO: create a spatial index interface in GeoInterface
    # Then, for each polygon that intersects, calculate the area of the intersection divided by the area of that source polygon
    # This is the weight of the source polygon in the final estimate
    coefficients = map(likely_polygon_indices) do i
        LG.area(LG.intersection(sources[i], polygon#=; target = GI.PolygonTrait()=#)) / source_areas[i]
    end
    # Normalize the coefficients so they sum to 1.  This should not be done for extensive variables (?)
    normalized_coefficients = coefficients ./ sum(coefficients)
    # Return the weighted average of the values per source polygon, as a NamedTuple.  This is equivalent to a "row" in the table.
    return NamedTuple{keys(values)}((sum(view(value_vector, likely_polygon_indices) .* normalized_coefficients) for value_vector in values))
end

# If you wanted to use other variables to weight the estimate somehow, it would be simple to copy this code and change it a bit 
# for a new estimator.