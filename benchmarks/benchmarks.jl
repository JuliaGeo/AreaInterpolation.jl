# Get data from the areal package

using RData, CodecBzip2

function _reprocess_r_polygons!(df::DataFrame)
    geoms = map(df.geometry) do geom_array
        GI.Polygon(GI.LinearRing.(geom_array .|> x -> GI.Point.(view.((x,), 1:size(x, 1), :))))
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

# Run benchmark
using Chairmarks
using ArealInterpolation
@be interpolate(Direct(), wards, race)

racy_wards = interpolate(Direct(), wards, race; features = (:TOTAL_E,))
