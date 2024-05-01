
#=
# Pycnophylactic interpolation

This file is meant to be the framework for a Julia port of 
https://github.com/pysal/tobler/blob/main/tobler/pycno/pycno.py,
but using Rasters.jl -- and potentially a bit more efficient.
=#

using Shapefile, ZipFile
using CairoMakie, GeoInterfaceMakie
import GeometryOps as GO, GeoInterface as GI
# First, we download the census tract data:
tracts_zipfile = download("https://ndownloader.figshare.com/files/20460645", "tracts.zip")
tracts = Shapefile.Table(tracts_zipfile)
poly(tracts.geometry; color = :transparent, strokewidth = 1)

# Then, we download the precinct data:
precincts_zipfile = download("https://ndownloader.figshare.com/files/20460549", "precincts.zip")
precincts = Shapefile.Table(precincts_zipfile)
poly(precincts.geometry; color = :transparent, strokewidth = 1)
# Hold on -- something looks wrong here!  It turns out that the precincts are not in the same projection as the tracts.  We can fix this by transforming the precincts to the tracts' projection.
# Reproject tracts to match the CRS of precincts
GI.crs(tracts), GI.crs(precincts)

# We can fix this by reprojecting `tracts` to the CRS of `precincts`:
import Proj
using DataFrames
tracts = GO.reproject(tracts; target_crs = GI.crs(precincts)) |> DataFrame
# There's a small issue - all the geometries are multipolygons.  GeometryOps doesn't yet support
# multipolygon clipping, so we need to convert them to polygons.
tracts.geometry = GI.getgeom.(tracts.geometry, 1)
precincts_df = DataFrame(precincts)
precincts_df.geometry = GI.getgeom.(precincts_df.geometry, 1) |> GO.tuples


# Now, we can also generate STRTrees for the tracts, which we'll use to speed the computation up:
using SortTileRecursiveTree
tracts_tree = STRtree(tracts.geometry)
tracts_areas = GO.area.(tracts.geometry)

# Now, we use Rasters.jl to perform pycnophylactic interpolation.
# NaNMath.jl provides NaN-ignoring reducer functions, which are useful here.
using Rasters, NaNMath
# First, we rasterize the tracts by ID.
# Here, we assign the missing value to be the max ID plus 1, so that
# we can keep the raster as an Int, and not worry about NaNs.  
# This also allows us to avoid branching in the loop, which helps 
# performance!
@time polygon_index_raster = rasterize(
		last,
		tracts; 
		size = (1000, 1000), 
		fill = 1:length(tracts.geometry),
		boundary = :touches, 
		missingval = length(tracts.geometry)+1,
		crs = GI.crs(precincts)
)
# Now, we can also process areas:
area_vec = zeros(Int, length(tracts.geometry)+1)
for cell in polygon_index_raster
		area_vec[cell] += 1
end
pop!(area_vec) 
plot(tracts.geometry; color = log10.(area_vec))
# That looks right to me!

# Now, we create the raster that we will operate on.  
tracts.var"pct Youth" = replace(tracts.var"pct Youth", missing => 0.0)
raster = rasterize(
		maximum, 
		tracts; 
		size = (1000, 1000), 
		fill = :var"pct Youth",
		boundary = :touches, 
		missingval = NaN,
		crs = GI.crs(precincts)
)

polygon_extent_cache = GI.extent.(tracts.geometry)
@time polygon_mask_caches = [boolmask(pol; to = crop(raster; to=pol)) for pol in tracts.geometry]

tol = 10^-3
convergence_criterion = NaNMath.maximum(raster) * tol

masked, value = polygon_mask_caches[8], tracts.var"pct Youth"[8]
cropped = crop(raster; to = tracts.geometry[8])
masked_cropped_view = view(cropped, (masked))
correction = (value - NaNMath.sum(masked_cropped_view)) / sum(masked)
masked_cropped_view .+= correction


function correction_a!(raster, polygons, polygon_mask_caches, values)
	for (polygon, masked, value) in zip(polygons, polygon_mask_caches, values)
		cropped = crop(raster; to = polygon, touches = false)
		masked_cropped_view = view(cropped, masked)
		correction = (value - NaNMath.sum(masked_cropped_view)) / sum(masked)
		masked_cropped_view .+= correction
	end
end

function correction_a!(view, value)
	correction = (value - sum(view)) / length(view)
	view .+= correction
end

@time correction_a!(raster, tracts.geometry, polygon_mask_caches, tracts.var"pct Youth")

function correction_m!(raster, polygons, polygon_mask_caches, values)
	for (polygon, masked, value) in zip(polygons, polygon_mask_caches, values)
		cropped = crop(raster; to = polygon, touches = true)
		masked_cropped_view = view(cropped, masked)
		correction = value / NaNMath.sum(masked_cropped_view)
		iszero(correction) || (masked_cropped_view .*= correction)
	end
end

function correction_m!(view, value)
	correction = value / sum(view)
	iszero(correction) || (view .*= correction)
end

"""
	masked_view_map!(f!, raster, polygons, values, mask_caches)

Apply `f!` to pairs of (view, value) for each polygon in `polygons`.
"""
function masked_view_map!(f!, raster, polygons, values, mask_caches)
	for (polygon, masked, value) in zip(polygons, mask_caches, values)
		cropped = crop(raster; to = polygon, touches = true)
		masked_cropped_view = view(cropped, masked)
		f!(masked_cropped_view, value)
	end
end


# To implement zero-derivative BC, could you use NaNMath???  That sounds cool...

# Zero boundary condition on borders.  To convert this to a zero 
# derivative boundary condition, one would need to get the polygons
# that lie along the convex hull, and buffer them outside that hull 
# such that the boundary points have the same value as those polygon points.

# Alternatively, one can find the nearest polygon to an exterior point using 
# `distance` and an STRtree query, then fill it with that polygon's value.
# That sounds somehow better than buffering -- or perhaps the rasterized version
# of buffering.  One would need to figure out a way to get a border polygon for
# the whole thing, though, which sounds somehow inefficient.  Unless you filled the whole
# Raster up...




function pycno_smooth!(raster, polygon_index_raster, stencil, reducer; maxiters, tol)
end

import GeoInterface as GI, GeometryOps as GO
using Rasters

p1 = GI.Polygon([[[-55965.680060140774, -31588.16072168928], [-55956.50771556479, -31478.09258677756], [-31577.548550575284, -6897.015828572996], [-15286.184961223798, -15386.952072224134], [-9074.387601621409, -27468.20712382156], [-8183.4538916097845, -31040.003969070774], [-27011.85123029944, -38229.02388009402], [-54954.72822634951, -32258.9734800704], [-55965.680060140774, -31588.16072168928]]])
p2 = GI.Polygon([[[-80000.0, -80000.0], [-80000.0, 80000.0], [-60000.0, 80000.0], [-50000.0, 40000.0], [-60000.0, -80000.0], [-80000.0, -80000.0]]])

fc = GI.FeatureCollection([GI.Feature(p1, properties = (;val=1)), GI.Feature(p2, properties = (;val=2))])

r1 = rasterize(last, [p1, p2]; size = (1000, 1000), fill = [1, 2])
using CairoMakie
plot(r1)

r1_view_p1 = crop(r1; to = p1)
r1_view_mask_p1 = boolmask(p1; to = r1_view_p1, touches = true)
r1_view_masked_p1 = view(r1_view_p1, r1_view_mask_p1) # fine
r1_view_masked_p1 = view(r1, r1_view_mask_p1) # errors - can we not error here? 