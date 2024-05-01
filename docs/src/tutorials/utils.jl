
using SIMD
function nan_aware_kernelproduct(hood::Stencils.AbstractKernelStencil)
    nan_aware_kernelproduct(Stencils.stencil(hood), Stencils.kernel(hood))
end
function nan_aware_kernelproduct(hood::Stencils.Stencil{<:Any,<:Any,L}, kernel) where L
	# all(isnan.(hood)) && return NaN # activate if you want to preserve more NaN volume.
    sum = zero(first(hood))
    SIMD.@simd for i in 1:L
        @inbounds sum += ifelse(isnan(hood[i]), 0, hood[i] * kernel[i])
    end
    return sum
end
# We don't actually need NaN, but it's nice to keep it around
# since the volume preserving correction exists, any "bleed" outside
# the area will be "refilled" to preserve the volume.


"""
	masked_view_map!(f!, raster, polygons, values, [mask_caches])

Apply `f!` to pairs of (view, value) for each polygon in `polygons`.

If `mask_caches` is not provided then it will be regenerated.  This can 
be useful when repeating the same computation on different underlying
arrays, although the indices could always be recycled.  Something to consider
later.
"""
function masked_view_map!(f!, raster, polygons, values, mask_caches = [boolmask(pol; to = crop(raster; to=pol)) for pol in polygons])
	for (polygon, masked, value) in zip(polygons, mask_caches, values)
		cropped = crop(raster; to = polygon, touches = true)
		masked_cropped_view = view(cropped, masked)
		f!(masked_cropped_view, value)
	end
end