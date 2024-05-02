#=
# Tracts to voting precincts

This tutorial is a Julia translation of https://pysal.org/tobler/notebooks/02_areal_interpolation_example.html.
=#

## Code to read shapefiles from zips
# This depends on https://github.com/JuliaGeo/Shapefile.jl/pull/113 for now, once that's merged and released it won't be needed.
# For now, run `]add Shapefile#as/zipfile` to get that branch.
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
# We use LibGEOS methods here because they are much faster than GeometryOps (by 10x)
# on large polygons like these (large in number of vertices).  GeometryOps is optimized 
# for 10-15 element polygons.
@time youth_percentages = map(precincts_df.geometry) do polygon
    likely_polygon_indices = query(tracts_tree, polygon)
    coefficients = map(likely_polygon_indices) do i
      LG.area(LG.intersection(tracts.geometry[i], polygon#=; target = GI.PolygonTrait()=#)) / tracts_areas[i]
    end
    s = sum(tracts.var"pct Youth"[likely_polygon_indices] .* coefficients ./ sum(coefficients)) 
    if ismissing(s)
      return NaN
    else 
      return s
    end
end

poly(precincts_df.geometry; color = youth_percentages, strokecolor = :black)