# # Tracts to voting precincts

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