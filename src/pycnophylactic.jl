#=
# Pycnophylactic interpolation

This file defines methods for pycnophylactic interpolation, and they are
split out such that the meat of the "pycnophylactic kernel" is accessible
externally in a simple way.  This allows animations etc to be done easily,
and also allows other methods to potentially build on the pycnophylactic
kernel.

The file is spread into two parts. The first part is the kernel, i.e., the 
functions needed for a single iteration of the pycnophylactic method.

The second section holds the definition of the iterative method and some
data munging functions.
=#

#=
## Pycnophylactic kernel
=#

"""
    pycno_iteration!(old, new, sa, polygon_views, vals, relaxation)::Float64

Perform a single iteration of the pycnophylactic algorithm, and overwrites
the values in `new` and `old` with the result.  Returns the absolute maximum 
change in the data.

## Steps

1. Convolve the stencil in `sa` with `old` (stored in `sa` as well).
2. Apply the relaxation term to `new` and `old`.
3. Apply the area based correction to `new`.
4. Reset any negative values to 0.
5. Apply the mass preserving correction to `new`.
6. Find the maximum change in the data.
7. Overwrite the old data with the new data.
"""
function pycno_iteration!(old, new, sa, polygon_views, vals, relaxation)
    # map `sa` and write the result to `new`
	Stencils.mapstencil!(nan_aware_kernelproduct, new, sa) 
	# Apply the relaxation term.  This is why the self element is 
    # left out in the kernel, though it could be kept in?  
    # That's a question for later.
	@. new = old * relaxation + (1-relaxation) * new
	# Apply the area based correction to `new`.  This preserves
    # the pycnophylactic property and the volume.  However, it may
    # cause some cells with lower density to go negative.  That is corrected
	for (view, value) in zip(polygon_views, vals)
		correction_a!(view, value)
	end
	# Reset negative values to 0
	for (linear_idx, value) in enumerate(new)
		value < 0 && (new[linear_idx] = 0.0)
	end
	# Apply the mass preserving correction to `new`.
	for (view, value) in zip(polygon_views, vals)
		correction_m!(view, value)
	end
	# Find the maximum change in the data.
	Δ_max = NaNMath.maximum(abs.(old .- new))
	# Overwrite the old data with the new data.
	old .= new
    return Δ_max
end

function pycno_iterate(raster, polygons, vals, relaxation, stencil, tolerance = 10^-3, maxiters = 1000)
    polygon_views = [
        begin
            cropped = Rasters.crop(raster; to=pol, touches = true)
            masked = Rasters.boolmask(pol; to = cropped, boundary = :touches) 
            view(cropped, masked)
        end for pol in polygons
    ]
    return pycno_iterate(raster, polygons, vals, polygon_views, relaxation, stencil, tolerance, maxiters)
end

function pycno_iterate(raster, polygons, vals, polygon_views, relaxation, stencil, tolerance, maxiters)
    # Here, we extract the data backing this raster in memory.
    # All operations are performed on "new" because it is 
    # synced up to the `polygon_views`.
    new = raster.data 
    # Old is just to hold + compare data.  At the end of each loop, 
    # we copy the new data to old.  Then, at the beginning of the next loop,
    # new receives the convolved version of old, and we can start the next iteration.
    old = deepcopy(raster.data)
    # This `StencilArray` is used to convolve the stencil with the data.
    sa = Stencils.StencilArray(old, stencil #= kernel =#)
    i = 1
    for _ in 1:maxiters
        Δ_max = pycno_iteration!(old, new, sa, polygon_views, vals, relaxation)
        if Δ_max < tolerance
            break
        end
        # Re-create the stencil array. 
        # TODO: This reallocates, since it has to pad the array.  
        # Find a way to avoid this.
        # One way may be to make `old` a view into a pre-padded array.
        sa = Stencils.StencilArray(old, stencil)
        i += 1
    end
    if i ≥ maxiters
        @warn "Maximum number of iterations ($maxiters) reached during pycnophylactic iteration.  Consider increasing `tolerance` for faster convergence, or increase `maxiters`."
    end
    # Faithfully reconstruct the original Raster with the new data, and return it.
    return Rasters.Raster(new, Rasters.dims(raster); missingval = Rasters.missingval(raster), crs = Rasters.crs(raster), metadata = Rasters.metadata(raster))
end

@inline function correction_a!(view, value)
	# This conserves the volume of the polygon.
	# Specifically, `value` is the value of the 
	# whole polygon initially (NOT per area),
	# and we look at the difference between that
	# and the sum of the values in the view.
	# We then divide by the number of cells in the view
	# to get the average correction per cell.
	correction = (value - NaNMath.sum(view)) / length(view)
	# Then, we increment the whole view by the correction.
	view .+= correction
end

# I believe this is the mass preserving correction.
@inline function correction_m!(view, value)
	correction = value / NaNMath.sum(view)
	iszero(correction) || (view .*= correction)
end

"""
    nan_aware_kernelproduct(hood::Stencils.Stencil{<:Any,<:Any,L}, kernel) where L

Compute the dot product of the kernel and the stencil, ignoring NaN values.  
This function is the equivalent of `Stencils.kernelproduct`.
"""
function nan_aware_kernelproduct(hood::Stencils.Stencil{<:Any,<:Any,L}, kernel) where L
	# all(isnan.(hood)) && return NaN # activate if you want to preserve more NaN volume.
    sum = zero(first(hood))
    SIMD.@simd for i in 1:L
        @inbounds sum += ifelse(isnan(hood[i]), 0, hood[i] * kernel[i])
    end
    return sum
end
nan_aware_kernelproduct(hood::Stencils.AbstractKernelStencil) = nan_aware_kernelproduct(Stencils.stencil(hood), Stencils.kernel(hood))



#=
## Interface functions
=#

function pycno_interpolate(raster::Rasters.Raster, source_polygons, source_vals, target_polygons, relaxation, stencil, tolerance = 10^-3, maxiters = 1000)
    pycno_raster = pycno_iterate(raster, source_polygons, source_vals, relaxation, stencil, tolerance, maxiters)
    per_polygon_values = Rasters.zonal(sum, pycno_raster; of = target_polygons, progress = false)
    return per_polygon_values
end

function pycno_interpolate(pycno::Pycnophylactic, source_polygons, source_vals, area_corrected_vals, target_polygons)
    raster = Rasters.rasterize(
        last,
        source_polygons;
        res = pycno.cellsize,
        fill = area_corrected_vals,
        boundary = :touches,
        missingval = NaN
    )
    return pycno_interpolate(raster, source_polygons, source_vals, target_polygons, pycno.relaxation, pycno.kernel, pycno.tol, pycno.maxiters)
end


function interpolate(pycno::Pycnophylactic, TargetTrait::Union{GI.FeatureCollectionTrait, Nothing}, SourceTrait::Union{GI.FeatureCollectionTrait, Nothing}, target, sources; features = nothing, threaded = true, kwargs...)
    # First, we extract the geometry and values from the source FeatureCollection
    source_geometries, source_values = decompose_to_geoms_and_values(sources; features)
    # Then, we also extract the geometries from the target FeatureCollection.  In this case,
    # we explicitly request all features, so that we can reconstruct the featurecollection later.
    target_geometries, target_values = decompose_to_geoms_and_values(target; features = setdiff(Tables.columnnames(target), GI.geometrycolumns(target)))
    # We also check that all features given in `features` are continuous.
    for feature in features
        if !isvaluecol(eltype(source_values[feature]))
            error("Feature $feature is not a continuous value column, but has eltype $(eltype(source_values[feature])).")
        end
    end

    # Now, we can take care of the tedious tasks first:
    # 1. Find cell-based areas per polygon
    polygon_index_raster = Rasters.rasterize(
		last,
		source_geometries; 
		res = pycno.cellsize, 
		fill = 1:length(source_geometries),
		boundary = :center, 
		missingval = length(source_geometries)+1,
    )
    # Now, we can also process areas:
    area_vec = zeros(Int, length(source_geometries)+1)
    for cell in polygon_index_raster
            area_vec[cell] += 1
    end
    pop!(area_vec) # Remove the value for cells that are not in any polygon
    
    interpolated_feature_values = NamedTuple{features}(map(features, source_values) do colname, val
        # Extensive variables are densities, intensive variables are counts.
        # This means we have to process them separately, and we need to do post-hoc
        # handling separately as well.
        # (total_val, area_corrected_val) =  if colname in extensive
            # total_val = val .* area_vec
            # area_corrected_val = val
            # (total_val, area_corrected_val)
        # else # column is intensive, assumed by default.
            # area_corrected_val = val ./ area_vec
            # total_val = val
            # (total_val, area_corrected_val)
        # end
        total_val = val
        area_corrected_val = val ./ area_vec # this is the same for extensive or intensive I think.
        pycno_interpolate(pycno, source_geometries, total_val, area_corrected_val, target_geometries)
    end)
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