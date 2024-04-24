
#=
# Pycnophylactic interpolation

This file is meant to be the framework for a Julia port of 
https://github.com/pysal/tobler/blob/main/tobler/pycno/pycno.py,
but using Rasters.jl -- and potentially a bit more efficient.
=#

## Code to read shapefiles from zips
import ZipFile, Shapefile
function read_shp_from_zipfile(zipfile)
  r = ZipFile.Reader(zipfile)
  # need to get dbx
  shpdata, shxdata, dbfdata, prjdata = nothing, nothing, nothing, nothing
  for f in r.files
    fn = f.name
    lfn = lowercase(fn)
    if endswith(lfn, ".shp")
      shpdata = IOBuffer(read(f))
    elseif endswith(lfn, ".shx")
      shxdata = read(f, Shapefile.IndexHandle)
    elseif endswith(lfn, ".dbf")
      dbfdata = Shapefile.DBFTables.Table(IOBuffer(read(f)))
    elseif endswith(lfn, "prj")
      prjdata = try
        Shapefile.GeoFormatTypes.ESRIWellKnownText(Shapefile.GeoFormatTypes.CRS(), read(f, String))
      catch
        @warn "Projection file $zipfile/$lfn appears to be corrupted. `nothing` used for `crs`"
        nothing 
      end
    end
  end
  close(r)
  @assert shpdata !== nothing
  shp = if shxdata !== nothing # we have shxdata/index 
    read(shpdata, Shapefile.Handle, shxdata)
  else
    read(shpdata, Shapefile.Handle)
  end 
  if prjdata !== nothing
    shp.crs = prjdata 
  end 
  return Shapefile.Table(shp, dbfdata)
end 

using Shapefile
using CairoMakie, GeoInterfaceMakie
import GeometryOps as GO, GeoInterface as GI
# First, we download the census tract data:
tracts_zipfile = download("https://ndownloader.figshare.com/files/20460645")
tracts = read_shp_from_zipfile(tracts_zipfile)
poly(tracts.geometry; color = :transparent, strokewidth = 1)

# Then, we download the precinct data:
precincts_zipfile = download("https://ndownloader.figshare.com/files/20460549")
precincts = read_shp_from_zipfile(precincts_zipfile)
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
)
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