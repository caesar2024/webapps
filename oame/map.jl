using Plotly
using PlotlyExtras
using NetCDF
using Contour
using Dates

t = get_layout("default.json")

t = ncread("../../air.2m.gauss.2021.nc", "time")
air = ncread("../../air.2m.gauss.2021.nc", "air")
lon = ncread("../../air.2m.gauss.2021.nc", "lon")
lat = ncread("../../air.2m.gauss.2021.nc", "lat")

T = air[:, :, 186] .- 273.15


c = contours(lon, lat, T, [-30.0])

l = levels(c)
line = lines(l[1])
xs = mapreduce(vcat, line) do l
    xs1, ys1 = coordinates(l)
    [xs1;NaN]
end

ys = mapreduce(vcat, line) do l
    xs1, ys1 = coordinates(l)
    [ys1;NaN]
end

trace1 = Dict{Symbol,Any}(
    :template => t,
    :type => "scattergeo",
    :lon => xs,
    :lat => ys,
    :mode => "lines",
    :line => Dict(:width => 2, :color => "rgb(0, 0, 0.5)"),
    :showlegend => true,
    :name => "-30"
)


c = contours(lon, lat, T, [-20.0])

l = levels(c)
line = lines(l[1])
xs = mapreduce(vcat, line) do l
    xs1, ys1 = coordinates(l)
    [xs1;NaN]
end

ys = mapreduce(vcat, line) do l
    xs1, ys1 = coordinates(l)
    [ys1;NaN]
end

trace2 = Dict{Symbol,Any}(
    :template => t,
    :type => "scattergeo",
    :lon => xs,
    :lat => ys,
    :mode => "lines",
    :line => Dict(:width => 2, :color => "rgb(0.5, 0, 0.5)"),
    :showlegend => true,
    :name => "-20"
)



c = contours(lon, lat, T, [-10.0])

l = levels(c)
line = lines(l[1])
xs = mapreduce(vcat, line) do l
    xs1, ys1 = coordinates(l)
    [xs1;NaN]
end

ys = mapreduce(vcat, line) do l
    xs1, ys1 = coordinates(l)
    [ys1;NaN]
end

trace3 = Dict{Symbol,Any}(
    :template => t,
    :type => "scattergeo",
    :lon => xs,
    :lat => ys,
    :mode => "lines",
    :line => Dict(:width => 2, :color => "rgb(200, 0, 0)"),
    :showlegend => true,
    :name => "0")


# xs, ys = coordinates(line[1])
# trace2 = Dict{Symbol,Any}(
#     :template => t,
#     :type => "scattergeo",
#     :lon => xs,
#     :lat => ys,
#     :mode => "lines",
#     :line => Dict(:width => 2, :color => "rgb(0, 0, 0)"),
#     :showlegend => true,
#     :name => "-20"
# )

data = [GenericTrace("scattergeo", trace1), GenericTrace("scattergeo", trace2),GenericTrace("scattergeo", trace3)]

layout1 = Dict{Symbol,Any}(
    :template => t,
    :dragmode => "zoom",
    :margin => Dict(:l => 0, :r => 0, :t => 0, :b => 0),
    :width => 600,
    :height => 600,
    :geo => Dict(
        :showcoastlines => true,
        :showcountries => true,
        :showsubunits => true,
        :scale => 10,
        # :showland => true,
        :oceancolor => "rgb(201, 224, 255)",
        :showocean => true,
        :showlakes => true,
        :showrivers => true,
        :scope => "world",
        :subunitcolor => "#FFF",
        :projection => Dict(
            :type => "orthographic",
            :scale => 1.4,
            :rotation => Dict(:lon => -110, :lat => 55),
        ),
        :lonaxis => Dict(:showgrid => true, :gridcolor => "rgb(130, 130, 130)"),
        :lataxis => Dict(:showgrid => true, :gridcolor => "rgb(130, 130, 130)"),
    ),
)

p = Plot(data, Layout(layout1))

# to_html("index.html", [p])