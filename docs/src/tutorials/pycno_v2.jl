using RData, CodecBzip2 # import data
using DataFrames, LinearAlgebra # data manipulation
using CairoMakie, GeoInterfaceMakie # plotting
using ProgressMeter # progress bar
import GeometryOps as GO, GeoInterface as GI # geo operations

function _reprocess_r_polygons!(df::DataFrame)
    geoms = map(df.geometry) do geom_array
        permutedims.(geom_array)
        GI.Polygon(GI.LinearRing.(permutedims.(geom_array) .|> vec .|> x -> reinterpret(GI.Point{false, false, Tuple{Float64, Float64}, Nothing}, x)))
    end
    df.geometry = geoms
    df
end

asthma = RData.load(download("https://github.com/chris-prener/areal/raw/07bda84887d9f2272babe91c2ccc1e438f27f162/data/ar_stl_asthma.rda"))["ar_stl_asthma"]
race = RData.load(download("https://github.com/chris-prener/areal/raw/07bda84887d9f2272babe91c2ccc1e438f27f162/data/ar_stl_race.rda"))["ar_stl_race"]
wards = RData.load(download("https://github.com/chris-prener/areal/raw/07bda84887d9f2272babe91c2ccc1e438f27f162/data/ar_stl_wards.rda"))["ar_stl_wards"]
wardsClipped = RData.load(download("https://github.com/chris-prener/areal/raw/07bda84887d9f2272babe91c2ccc1e438f27f162/data/ar_stl_wardsClipped.rda"))["ar_stl_wardsClipped"]
_reprocess_r_polygons!(asthma)
_reprocess_r_polygons!(race)
_reprocess_r_polygons!(wards)
_reprocess_r_polygons!(wardsClipped)

# Now, we use Rasters.jl to perform pycnophylactic interpolation.
# NaNMath.jl provides NaN-ignoring reducer functions, which are useful here.
using Rasters, NaNMath, Stencils
# First, we rasterize the tracts by ID.
# Here, we assign the missing value to be the max ID plus 1, so that
# we can keep the raster as an Int, and not worry about NaNs.  
# This also allows us to avoid branching in the loop, which helps 
# performance!
@time polygon_index_raster = rasterize(
		last,
		race.geometry; 
		size = (1000, 1000), 
		fill = 1:length(race.geometry),
		boundary = :center, 
		missingval = length(race.geometry)+1,
)
# Now, we can also process areas:
area_vec = zeros(Int, length(race.geometry)+1)
for cell in polygon_index_raster
		area_vec[cell] += 1
end
pop!(area_vec) # Remove the value for cells that are not in any polygon
plot(race.geometry; color = log10.(area_vec), axis = (; aspect = DataAspect()))
# That looks right to me!

# Here, we define some kernels for the pycnophylactic interpolation.
# We currently use the five point stencil, but that can exacerbate 
# anisotropies.  We could also use a stencil which doesn't do that,
# like one of the window stencils.
# Note that here I'm speaking about stencils in the mathematical sense,
# but in DSP/image/Stencils.jl terms this is a "kernel", with weights
# and a structure which is the actual "stencil".
five_point_kernel = Stencils.Kernel(Stencils.Cross(1, 2), LinearAlgebra.normalize([0.5, 0.5, 0, 0.5, 0.5], 1))
five_point_mat = [0 1 0; 1 0 1; 0 1 0]
gamma_mat = [1/2 0 1/2; 0 0 0; 1/2 0 1/2]
oono_puri_kernel = let γ = 1/2
	Stencils.Kernel(Stencils.Window(1, 2), LinearAlgebra.normalize(vec((1 - γ) .* five_point_mat .+ gamma_mat .* γ), 1))
end
mehrstellen_kernel = let γ = 1/3
	Stencils.Kernel(Stencils.Window(1, 2), LinearAlgebra.normalize(vec((1 - γ) .* five_point_mat .+ gamma_mat .* γ), 1))
end

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

# First, we create a storage array in a Raster, which will be written to.
# This is considerably less efficient than switching arrays, but it makes
# doing the masking more efficient.
# Thankfully, `raster` already exists, so we just use that.  We don't care about
# modifying it because the user will never see it (or the user wants the modified state)
relaxation = 0.2
polygons = race.geometry     # These are the polygons that we will be working on.
vals = race.TOTAL_E          # These are the original values associated with polygons.
cell_vals = vals ./ area_vec # These are the values of the polygons, divided by the area.
raster = rasterize(
		maximum, 
		race; 
		size = (1000, 1000), 
		fill = cell_vals, # divide cell values by area
		boundary = :touches, 
		missingval = NaN,
)
# Create a vector of pre-constructed views into the polygon.
polygon_views = [
	begin
		cropped = crop(raster; to=pol, touches = true)
		masked = boolmask(pol; to = cropped, boundary = :touches) 
		view(cropped, masked)
	end for pol in polygons
]
# Get the underlying data from the raster.
new = raster.data # all operations are performed on "new" but this is what's synced up to the views.
# Old is just to hold + compare data.  At the end of each loop, 
# we copy the new data to old.  Then, at the beginning of the next loop,
# new receives the convolved version of old, and we can start the next iteration.
old = deepcopy(raster.data)
sa = StencilArray(old, oono_puri_kernel #= kernel =#)
# Create a StencilArray with this data
pm = ProgressMeter.Progress(100)
f, a, p = heatmap(raster; colorrange = NaNMath.extrema(raster.data), axis = (; aspect = DataAspect()))
record(f, "oono_puri_iterations.mp4", 1:300) do i # This will be replaced by a for loop -- but is a good source of diagnostic videos.
	# The internals here are the "pycnophylactic kernel".
	global sa
	# map `sa` and write the result to `new`
	mapstencil!(nan_aware_kernelproduct, new, sa) 
	# Apply the relaxation term.
	@. new = old * relaxation + (1-relaxation) * new
	# Apply the area based correction to `new`.
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
	max_change = only(Makie.Formatters.scientific([round(Δ_max; sigdigits = 4)]))
	# Overwrite the old data with the new data.
	old .= new
	sa = StencilArray(old, oono_puri_kernel)
	# Update the plot!
	p[3] = sa.parent
	a.title = "Iteration $i"
	a.subtitle = "Δ = $max_change"
	update!(pm, i; desc = "Max change $(max_change)")
end	
# plot(sa.source)
plot(old)
tol = 10^-3
convergence_criterion = NaNMath.maximum(raster) * tol
relaxation = 0.2
sa = StencilArray(raster, oono_puri_kernel)

# A single iteration's implementation is below.
old = copy(value_array)

function correction_a!(view, value)
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
function correction_m!(view, value)
	correction = value / NaNMath.sum(view)
	iszero(correction) || (view .*= correction)
end


