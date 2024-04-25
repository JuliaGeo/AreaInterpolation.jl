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
