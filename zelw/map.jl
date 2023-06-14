using Plotly
using PlotlyExtras
using NetCDF
using Contour
using Dates
using JSON

t = ncread("../../air.2m.gauss.2020.nc", "time")
air = ncread("../../air.2m.gauss.2020.nc", "air")
lon = ncread("../../air.2m.gauss.2020.nc", "lon")
lat = ncread("../../air.2m.gauss.2020.nc", "lat")

t = Hour.(t) .+ DateTime(1800, 1, 1, 0, 0.0)

ss = DateTime(2020, 3, 28, 0, 0, 0)
ee = DateTime(2020, 4, 20, 0, 0, 0)

ii = (t .> ss) .& (t .< ee) .& (Time.(t) .== Time(12, 0, 0))
Ts = air[:, :, ii] .- 273.15

function get_contours(T, temp)
    c = contours(lon, lat, T, [temp])

    l = levels(c)
    line = lines(l[1])
    xs = mapreduce(vcat, line) do l
        xs1, ys1 = coordinates(l)
        return [xs1; NaN]
    end

    ys = mapreduce(vcat, line) do l
        xs1, ys1 = coordinates(l)
        return [ys1; NaN]
    end

    return xs, ys
end

r = map(i -> get_contours(Ts[:, :, i], -30), 1:sum(ii))
xs30 = map(x -> x[1], r)
ys30 = map(x -> x[2], r)

r = map(i -> get_contours(Ts[:, :, i], -20), 1:sum(ii))
xs20 = map(x -> x[1], r)
ys20 = map(x -> x[2], r)

r = map(i -> get_contours(Ts[:, :, i], -10), 1:sum(ii))
xs10 = map(x -> x[1], r)
ys10 = map(x -> x[2], r)

r = map(i -> get_contours(Ts[:, :, i], 0), 1:sum(ii))
xs0 = map(x -> x[1], r)
ys0 = map(x -> x[2], r)

data = Dict(
    "t" => t[ii],
    "xs0" => xs0,
    "xs0" => xs0,
    "xs10" => xs10,
    "xs20" => xs20,
    "xs30" => xs30,
    "ys10" => ys10,
    "ys20" => ys20,
    "ys30" => ys30,
)

jdata = json(data)

open("data.js", "w") do file
    write(file, "const x = ")
    return JSON.print(file, jdata)
end

t = get_layout("default.json")

function read_json(file)
    open(file, "r") do f
        return JSON.parse(f)
    end
end

area = read_json("../../median.json")

i = 1

# roi = Dict(
#   :type => "FeatureCollection",
#   :features => [ Dict(
#       :type => "Feature",
#       :geometry => Dict(
#         :type => "Polygon",
#         :coordinates => [
#           [
#             [100.0, 0.0],
#             [101.0, 0.0],
#             [101.0, 1.0],
#             [100.0, 1.0],
#             [100.0, 0.0]
#           ]
#         ]
#       ),
#       "properties": {
#         "prop0": "value0",
#         "prop1": { "this": "that" }
#       }
#   )
#   ]
# )

trace0 = Dict{Symbol,Any}(
    :template => t,
    :geojson => area,
    :featureidkey => "properties.INDEX",
    :z => ones(121) .* 0,
    :locations => 0:121,
    :showscale => false,
    :colorscale => [["0", "#AAA"]],
)

trace0a = Dict{Symbol,Any}(
    :template => t,
    :mode => "lines",
    :lon => [
        range(-5; stop = 22, length = 10)
        [22, 22]
        range(22; stop = -5, length = 10)
        [-5]
    ],
    :lat => [70 * ones(10); [70, 80]; 80 * ones(10); [70]],
    :showscale => true,
    :visible => "legendonly",
    :line => Dict(:width => 3, :color => "rgb(0.4, 0.4, 0.4)"),
    :name => "ROI",
)

trace1 = Dict{Symbol,Any}(
    :template => t,
    :type => "scattergeo",
    :lon => xs30[i],
    :lat => ys30[i],
    :mode => "lines",
    :line => Dict(:width => 2, :color => "rgb(0, 0, 0.5)"),
    :showlegend => true,
    :name => "-30",
)

trace2 = Dict{Symbol,Any}(
    :template => t,
    :lon => xs20[i],
    :lat => ys20[i],
    :mode => "lines",
    :line => Dict(:width => 2, :color => "rgb(0, 0, 0.5)"),
    :showlegend => true,
    :name => "T = −20°C",
)

trace3 = Dict{Symbol,Any}(
    :template => t,
    :lon => xs10[i],
    :lat => ys10[i],
    :mode => "lines",
    :line => Dict(:width => 2, :color => "rgb(0.5, 0, 0.5)"),
    :showlegend => true,
    :name => "T = −10°C",
)

trace4 = Dict{Symbol,Any}(
    :template => t,
    :lon => xs0[i],
    :lat => ys0[i],
    :mode => "lines",
    :line => Dict(:width => 2, :color => "rgb(200, 0, 0)"),
    :showlegend => true,
    :name => "T = 0°C",
)

trace5 = Dict{Symbol,Any}(
    :template => t,
    :lon => [20.2253],
    :lat => [67.8558],
    :mode => "markers",
    :marker => Dict(:color => "#000", :size => 8, :symbol => "square"),
    # :line => Dict(:width => 2, :color => "rgb(200, 0, 0)"),
    :showlegend => true,
    :name => "Kiruna",
)

trace6 = Dict{Symbol,Any}(
    :template => t,
    :lon => [20.9752],
    :lat => [77.8750],
    :mode => "markers",
    :marker => Dict(:color => "#000", :size => 8, :symbol => "hexagon"),
    :showlegend => true,
    :name => "Svalbard",
)

trace7 = Dict{Symbol,Any}(
    :template => t,
    :lon => [-21.9408],
    :lat => [64.1470],
    :mode => "markers",
    :marker => Dict(:color => "#000", :size => 8, :symbol => "x"),
    :showlegend => true,
    :name => "Reykjavík",
)

tracetext = Dict(
    :template => t,
    :lon => [35, -9, 5, 6],
    :lat => [75, 72, 69, 77.5],
    :mode => "text",
    :text => ["Barents Sea", "Greenland Sea", "Norwegian Sea", "Fram Strait"],
    :font => Dict(:size => 12, :color => "#7f7f7f"),
    :showlegend => false,
);

data = [
    GenericTrace("choropleth", trace0),
    # GenericTrace("scattergeo", trace1),
    GenericTrace("scattergeo", trace2),
    GenericTrace("scattergeo", trace3),
    GenericTrace("scattergeo", trace4),
    GenericTrace("scattergeo", trace0a),
    GenericTrace("scattergeo", trace5),
    GenericTrace("scattergeo", trace6),
    GenericTrace("scattergeo", trace7),
    GenericTrace("scattergeo", tracetext),
]

layout1 = Dict{Symbol,Any}(
    # :template => t,
    :dragmode => "false",
    :margin => Dict(:l => 10, :r => 0, :t => 0, :b => 0),
    # :width => 500,
    # :height => 460,
    # :title => Dict(:text =>"Cold Air Outbreak March 28, 2020", :y => 0.96),
    # :legend => Dict(:y => 0.92),
    # :coloraxis => Dict(:showscale => false, :cmax => 1),
    :geo => Dict(
        :resolution => 50,
        :showcountries => true,
        :showland => true,
        :landcolor => "#FEFDED",
        :oceancolor => "#9DDBFF",
        :lakecolor => "#006699",
        :showocean => true,
        :showlakes => true,
        :scope => "world",
        :projection => Dict(
            :type => "orthographic",
            :scale => 3.9,
            :rotation => Dict(:lon => -10, :lat => 70),
        ),
        :lonaxis => Dict(:showgrid => true, :gridcolor => "rgb(50, 110, 50)"),
        :lataxis => Dict(:showgrid => true, :gridcolor => "rgb(50, 50, 50)"),
    ),
)

p = Plot(data, Layout(layout1))
#js = JSON.lower(p)
# setindex!(js[:config], "pk.eyJ1IjoibWRwZXR0ZXJzIiwiYSI6ImNsaXQ3ang5ajFuc24zZ21ycjN4NTNkYzQifQ.8bKl33RtSffHfMNgaa3Jqw"
# , :mapboxAccessToken)

#p

to_html("index.html", [p])