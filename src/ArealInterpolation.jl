module ArealInterpolation

# Multiple methods.  We start with the regular method, i.e., simple area interpolation without any redeeming features.
# Then, we'll branch out into pycnophylactic interpolation, which is still free of external information.

# Following this, we implement dasymetric interpolation.

using GeoInterface, GeometryOps
import GeometryOps as GO, GeoInterface as GI, LibGEOS as LG

import Rasters, Stencils # for pycnophylactic and dasymetric interpolation
import Tables, DataFrames # for table manipulation and to process table input
import SortTileRecursiveTree # for STRtrees to make geometry queries more efficient

include("types.jl")
include("utils.jl")
include("regular.jl")

export interpolate
export Direct, Pycno, Pycnophylactic, Dasymetric

end
