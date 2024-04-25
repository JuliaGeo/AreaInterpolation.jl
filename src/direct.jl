function interpolate(::Direct, polygon, sources::AbstractVector, values::NamedTuple, source_areas, source_rtree; kwargs...) # should be 2 params `intensive` and `extensive` as well...
    likely_polygon_indices = SortTileRecursiveTree.query(source_rtree, polygon)
    coefficients = map(likely_polygon_indices) do i
        LG.area(LG.intersection(sources[i], polygon#=; target = GI.PolygonTrait()=#)) / source_areas[i]
    end
    normalized_coefficients = coefficients ./ sum(coefficients)
    return NamedTuple{keys(values)}((sum(view(value_vector, likely_polygon_indices) .* normalized_coefficients) for value_vector in values))
end

