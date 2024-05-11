isvaluecol(::Type{Union{T, Missing}}) where T = isvaluecol(T)
isvaluecol(::Type{<: Number}) = true
isvaluecol(something) = false

"""
    decompose_to_geoms_and_values(sources; features = nothing)

Decompose a table or feature collection into geometries and values.
Returns `(geometries::Vector{Geometry}, values::NamedTuple{Vector})`.  

`values` is a namedtuple of each value column in `sources`.  A value column
is something whose eltype satisfies `isvaluecol`, and is currently `Union{Number, Missing}`.
"""
function decompose_to_geoms_and_values(sources; features = nothing) # sources must be a Tables.Table or a GI.FeatureCollection
    geometry_column = first(GI.geometrycolumns(sources))
    namedtuple = Tables.columntable(sources)
    feature_columns = setdiff(Tables.columnnames(namedtuple), (geometry_column,))
    value_columns = if isnothing(features)
        feature_columns[map(x -> isvaluecol(eltype(namedtuple[x])), feature_columns)]
    else
        features
    end
    geometries = namedtuple[geometry_column]
    values = namedtuple[value_columns]
    return (geometries, NamedTuple(zip(value_columns, values)))
end


"""
    rasterized_polygon_areas(source_geometries, cellsize::Real)::Vector{Float64}

Compute the rasterized area of each polygon in `source_geometries`, on a 
Raster with resolution `cellsize`.  `sour`

Returns a vector of cell counts per source geometry.
"""
function rasterized_polygon_areas(source_geometries, cellsize)
    polygon_index_raster = Rasters.rasterize(
		last,
		source_geometries; 
		res = cellsize, 
		fill = 1:size(source_geometries, 1),
		boundary = :center, 
		missingval = size(source_geometries, 1)+1,
    )
    # Now, we can also process areas:
    area_vec = zeros(Int, size(source_geometries, 1)+1)
    for cell in polygon_index_raster
            area_vec[cell] += 1
    end
    pop!(area_vec) # Remove the value for cells that are not in any polygon
    return area_vec
end

# We need the ability to set up a targeting