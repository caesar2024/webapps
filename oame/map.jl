using Plotly
using PlotlyExtras
using NetCDF
using Contour
using Dates
using JSON

t = ncread("../../air.2m.gauss.2021.nc", "time")
air = ncread("../../air.2m.gauss.2021.nc", "air")
lon = ncread("../../air.2m.gauss.2021.nc", "lon")
lat = ncread("../../air.2m.gauss.2021.nc", "lat")

t = Hour.(t) .+ DateTime(1800, 1, 1, 0, 0.0)

ss = DateTime(2021, 2, 2, 0, 0, 0)
ee = DateTime(2021, 2, 22, 0, 0, 0)

ii = (t .> ss) .& (t .< ee) .& (Time.(t) .== Time(12, 0, 0))
t[ii]

Ts = air[:, :, ii] .- 273.15

T = Ts[:, :, 1]

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

data = Dict(
    "t" => t[ii],
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
    JSON.print(file, jdata)
end

# t = get_layout("default.json")

# trace1 = Dict{Symbol,Any}(
#     :template => t,
#     :type => "scattergeo",
#     :lon => xs30[1],
#     :lat => ys30[1],
#     :mode => "lines",
#     :line => Dict(:width => 2, :color => "rgb(0, 0, 0.5)"),
#     :showlegend => true,
#     :name => "-30",
# )

# trace2 = Dict{Symbol,Any}(
#     :template => t,
#     :type => "scattergeo",
#     :lon => xs20[1],
#     :lat => ys20[1],
#     :mode => "lines",
#     :line => Dict(:width => 2, :color => "rgb(0.5, 0, 0.5)"),
#     :showlegend => true,
#     :name => "-20",
# )

# trace3 = Dict{Symbol,Any}(
#     :template => t,
#     :type => "scattergeo",
#     :lon => xs10[1],
#     :lat => ys10[1],
#     :mode => "lines",
#     :line => Dict(:width => 2, :color => "rgb(200, 0, 0)"),
#     :showlegend => true,
#     :name => "-10",
# )

# data = [
#     GenericTrace("scattergeo", trace1),
#     GenericTrace("scattergeo", trace2),
#     GenericTrace("scattergeo", trace3),
# ]

# layout1 = Dict{Symbol,Any}(
#     :template => t,
#     :dragmode => "zoom",
#     :margin => Dict(:l => 0, :r => 0, :t => 0, :b => 0),
#     :width => 800,
#     :height => 530,
#     :geo => Dict(
#         :resolution => 50,
#         :showcoastlines => true,
#         :showcountries => true,
#         :showsubunits => true,
#         :subunitwidth => 0.5,
#         :showland => true,
#         :oceancolor => "rgb(201, 224, 255)",
#         :lakecolor => "rgb(201, 224, 255)",
#         :showocean => true,
#         :showlakes => true,
#         :scope => "north america",
#         :projection => Dict(
#             :type => "orthographic",
#             :rotation => Dict(:lon => -110, :lat => 50),
#         ),
#         :lonaxis => Dict(:showgrid => true, :gridcolor => "rgb(210, 210, 210)"),
#         :lataxis => Dict(:showgrid => true, :gridcolor => "rgb(210, 210, 210)"),
#     ),
# )

# p = Plot(data, Layout(layout1))

# to_html("base.html", [p])