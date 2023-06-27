using Plotly
using PlotlyExtras
using NetCDF
using Contour
using Dates
using Geodesy

function findlat(mlon)
    frange = 1852 * 1000.0
    kir = LatLon(; lat = 67.8558, lon = 20.2253)

    lats = 10:0.1:90
    dist = map(lats) do mlat
        point = LatLon(; lat = mlat, lon = mlon)
        d = euclidean_distance(point, kir) - frange
        return d
    end
    ii = sortperm(abs.(dist))
    lats[ii]
    return lats[ii][1:2]
end

lons = -29.3:0.1:70
lats = map(findlat, lons)
lats = hcat(lats...)'[:, :]

p = [lats[:, 1]; lats[:, 2]]
q = [lons; lons]

coord = map((lat, lon) -> LatLon(; lat = lat, lon = lon), p, q)
sorted = []
push!(sorted, coord[1])
deleteat!(coord, 1)

while (length(coord) >= 1)
    tdists = map(c -> euclidean_distance(sorted[end], c), coord)
    xs, is = findmin(abs.(tdists))
    push!(sorted, coord[is])
    deleteat!(coord, is)
end

mlats = map(x -> x.lat, sorted)
mlons = map(x -> x.lon, sorted)
mlats = [mlats;mlats[1]]
mlons = [mlons;mlons[1]]

t = get_layout("default.json")

function read_json(file)
    open(file, "r") do f
        return JSON.parse(f)
    end
end

area = read_json("../../median.json")
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
    :line => Dict(:width => 3, :color => "rgb(0.4, 0.4, 0.4)"),
    :name => "ROI",
)

trace1 = Dict{Symbol,Any}(
    :template => t,
    :mode => "lines",
    :lon => mlons,
    :lat => mlats,
    :showscale => true,
    :line => Dict(:width => 2, :color => "rgb(0, 0, 0)", :dash => "dash"),
    :name => "1000 nmi",
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
    GenericTrace("scattergeo", trace1),
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
    # :width => 900,
    # :height => 460,

    :geo => Dict(
        :resolution => 50,
        :showcountries => true,
        :showland => true,
        :landcolor => "#FEFDED",
        :oceancolor => "#9DDBFF",
        :lakecolor => "#9DDBFF",
        :showocean => true,
        :showlakes => true,
        :scope => "world",
        :projection => Dict(
            :type => "orthographic",
            :scale => 3.2,
            :rotation => Dict(:lon => -10, :lat => 70),
        ),
        :lonaxis => Dict(:showgrid => true, :gridcolor => "rgb(50, 110, 50)"),
        :lataxis => Dict(:showgrid => true, :gridcolor => "rgb(50, 50, 50)"),
    ),
)

p = Plot(data, Layout(layout1))

to_html("index.html", [p])