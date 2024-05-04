#=
# Benchmarks

This file contains Julia benchmarks for areal interpolation.  

## St. Louis wards
=#


# Get data from the areal package

using RData, CodecBzip2, DataFrames

function _reprocess_r_polygons!(df::DataFrame)
    geoms = map(df.geometry) do geom_array
        permutedims.(geom_array)
        GI.Polygon(GI.LinearRing.(permutedims.(geom_array) .|> vec .|> x -> reinterpret(GI.Point{false, false, Float64, Nothing}, x)))
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

racy_wards = interpolate(Direct(), wards, race; features = (:TOTAL_E,))

# Run benchmark in Julia
using Chairmarks
using AreaInterpolation
multi_threaded_benchmark = @be interpolate(Direct(), $wards, $race; features = $((:TOTAL_E,))) seconds=3
single_threaded_benchmark = @be interpolate(Direct(), $wards, $race; features = $((:TOTAL_E,)), threaded = false) seconds=3
# Multithreaded 9ms, single-threaded 43ms, R 65ms median timings!!

# # Plotting
# Get R benchmark
r_benchmark = RData.load(joinpath(@__DIR__, "benchmarks.RData"))["res"]
r_benchmark.expr.pool.levels .= (x ->  contains(x, "st_interpolate") ? "R (sf)" : "R (areal)").(r_benchmark.expr.pool.levels)
r_benchmark
using DataFrames, Statistics
r_gdf = groupby(r_benchmark, :expr)
r_stats = [(mean(r_gdf[key].time) / 10^6, std(r_gdf[key].time) / 10^6, string(key.expr)) for key in keys(r_gdf)]

xs = [1, 2, 3, 4]
ys = [Statistics.mean(multi_threaded_benchmark).time * 10^3, Statistics.mean(single_threaded_benchmark).time * 10^3, first.(r_stats)...]
errs = [Statistics.std(multi_threaded_benchmark).time * 10^3, Statistics.std(single_threaded_benchmark).time * 10^3, getindex.(r_stats, 2)...]
xlabels = ["Multithreaded", "Single-threaded", last.(r_stats)...]

using CairoMakie, MakieThemes
with_theme(MakieThemes.bbc()) do 
    f, a, p = scatter(
        xs, ys;
        axis = (;
            title = "Benchmarking regular interpolation",
            subtitle = Makie.rich("On the St. Louis wards dataset from ", rich("areal"; font = :mono)),
            ylabel = "Median time to execute (ms)",
            xticks = (xs, xlabels),
            xticksvisible = true,
            xticklabelsvisible = true,
            ytickformat = values -> string.(round.((Int,), values)) .* " ms",
            yticks = Makie.WilkinsonTicks(7; k_min = 3, k_max = 10),
        ),
        figure = (;
            fonts = (;
                regular = "Helvetica",
                bold = "Helvetica Neue Bold",
                italic = "Helvetica Oblique",
                mono = "Fira Mono",
            ),
        )
    )
    errorbars!(
        a,
        xs,
        ys,
        errs;
        color = (:gray, 0.4)
    )
    f
end


#=

## Texas precincts

=#

