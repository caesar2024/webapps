using Dates
using Chain
using MLStyle
using LsqFit
using SpecialFunctions
using JSON
using Plotly
using PlotlyExtras
using Plots
using Plots.PlotMeasures

include("reader.jl")
include("rh_functions.jl")
include("processingroutines.jl")

@isdefined(nc) || (nc = read_netCDF())

data = subset(DateTime(2023, 5, 1, 0, 0, 0), DateTime(2023, 05, 9, 0, 0, 0), nc)

# mft = map(1:length(data.tf)) do i
#     return fitme(
#         data.tf,
#         data.ccn_supersaturation,
#         data.diameter_mobility_midpoints,
#         data.response_function_ccn,
#         data.response_function_cpc_count,
#         data.denuder_flag,
#         i,
#         "denuded_event",
#     )
# end

# df = @chain mft begin
#     map(_) do x
#         if ~isnothing(x)
#             DataFrame(; t = x[5], k = x[2], denuded = x[3], ss = x[4])
#         else
#             nothing
#         end
#     end

#     filter(x -> .~isnothing(x), _)
#     foldl(vcat, _)
# end

sub(ss, d) = filter([:ss, :denuded] => (x, y) -> (x .== ss) .& (y .== d), df)

st = "2023-05-2 0:00:00"
et = "2023-05-7 0:00:00"

t = get_layout("default.json")
ii = (data.diameter_mobility_midpoints .> 30) .& (data.diameter_mobility_midpoints .< 250)
jj = data.tf .> DateTime(2023,5,1,1,0,0)

traceX = Dict(
    :mode => "lines",
    :x => [st, et],
    :y => [28, 28],
    :name => "",
    :line => Dict(:color => "rgb(0, 0, 0)", :width => 1),
    :showlegend => false
)

traceY = Dict(
    :mode => "lines",
    :x => [st, st],
    :y => [0, 250.0],
    :name => "",
    :line => Dict(:color => "rgb(0, 0, 0)", :width => 1),
    :showlegend => false
)

trace1a = Dict{Symbol,Any}(
    :x => data.tf[jj],
    :y => reverse(data.diameter_mobility_midpoints[ii]),
    :z => reverse(data.dN_dlog_Dp_DMA_count_2[ii, jj]; dims = 1),
    :zmin => 0,
    :zmax => 5000,
    :colorscale => "Portland",
    :colorbar => Dict(
        :title => "<b> dN/dlnD (cm⁻³)</b>",
        :tickfont => Dict(:size => 10),
        :nticks => 5,
        :orientation => "h",
        :outlinewidth => 0,
        :thickness => 8,
        :xanchor => "left",
        :x => 0.0,
        :xpad => 0,
        :ticklen => 7,
        :ticks => "inside",
        :len => 1.0,
        :side => "top",
        :y => 0.88,
        :range => [0, 1000],
    ),
)

trace1b = Dict(
    :mode => "lines",
    :x => [data.tf[1], data.tf[end]],
    :y => [45, 45],
    :name => "Dc @ s = 0.8%",
    :line => Dict(:color => "rgb(0.6,0.6,0.6)", :width => 1),
);

trace1c = Dict(
    :mode => "lines",
    :x => [data.tf[1], data.tf[end]],
    :y => [62, 62],
    :name => "Dc @ s = 0.4%",
    :line => Dict(:color => "rgb(0.3,0.3,0.3)", :width => 1),
);

trace1d = Dict(
    :mode => "lines",
    :x => [data.tf[1], data.tf[end]],
    :y => [80, 80],
    :name => "Dc @ s = 0.2%",
    :line => Dict(:color => "rgb(0.0,0.0,0.0)", :width => 1),
);

layout1 = Dict{Symbol,Any}(
    :title => "",
    :font => Dict(:size => 12),
    :margin => Dict(:l => 60, :r => 158, :t => 20, :b => 10, :pad => 4),
    :template => t,
    :xaxis => Dict(:range => [st, et], :showticklabels => false, :ticks => "inside",),
    :yaxis => Dict(
        :type => "log",
        :tickvals => [30, 50, 100, 200],
        :title => Dict(:text => "D (nm)", :standoff => 9),
        :range => [log10(27), log10(300)]
    ),
    :height => 160,
    :showlegend => true,
)

p1 = GenericTrace("heatmap", trace1a)
p2 = GenericTrace("line", trace1b)
p3 = GenericTrace("line", trace1c)
p4 = GenericTrace("line", trace1d)
panel1 = Plot([p1, p2, p3, p4, GenericTrace("line", traceX), GenericTrace("line", traceY)], Layout(layout1));

trace2a = Dict(
    :x => data.tf,
    :y => data.sample_relative_humidity,
    :name => "RH",
    :line => Dict(:color => "rgb(0.0, 0, 0)", :width => 1.0),
)

layout2 = Dict(
    :template => t,
    :font => Dict(:size => 12),
    :showlegend => true,
    :margin => Dict(:l => 60, :r => 158, :t => 5, :b => 10, :pad => 4),
    :height => 90,
    :xaxis => Dict(
        :side => "bottom",
        :ticks => "inside",
        :range => [st, et],
        :showticklabels => false,
        :minor => Dict(:showgrid => true, :gridcolor => "#eeeeee"),
    ),
    :yaxis => Dict(
        :title => Dict(:text => "RH (%)", :standoff => 19),
        :range => [-1, 45],
        :ticks => "outside",
        :tickvals => [0, 20, 40],
    ),
)

panel2 = Plot([GenericTrace("line", trace2a), GenericTrace("line", traceY)], Layout(layout2))

df1 = sub(0.2, false)
df2 = sub(0.2, true)
aa = df1[!, :k] .> 0.05
bb = df2[!, :k] .> 0.05

trace3a = Dict(
    :mode => "lines+markers",
    :x => df2[bb, :t],
    :y => df2[bb, :k],
    :name => "0.2%, denuded",
    :line => Dict(:color => "rgb(0.72, 0.53, 0.04)", :width => 1),
)

trace3b = Dict(
    :mode => "lines+markers",
    :x => df1[aa, :t],
    :y => df1[aa, :k],
    :name => "0.2%, denuded",
    :line => Dict(:color => "rgb(0.64, 0.71, 0.8)", :width => 1),
)

layout3 = Dict(
    :margin => Dict(:l => 60, :r => 158, :t => 0, :b => 12, :pad => 4),
    :height => 90,
    :template => t,
    :xaxis => Dict(
        :side => "bottom",
        :ticks => "inside",
        :range => [st, et],
        :showticklabels => false,
        :minor => Dict(:showgrid => true, :gridcolor => "#eeeeee"),
    ),
    :yaxis => Dict(
        :title => Dict(:text => "κ (-)", :standoff => 30),
        :range => [-0.02, 1.15],
        :ticks => "outside",
        :tickvals => [0, 0.2, 0.4, 0.6, 0.8, 1.0],
    ),
)

panel3 =
    Plot([GenericTrace("line", trace3a), GenericTrace("line", trace3b),  GenericTrace("line", traceY)], Layout(layout3))

df1 = sub(0.4, false)
df2 = sub(0.4, true)
aa = df1[!, :k] .> 0.05
bb = df2[!, :k] .> 0.05

trace4a = Dict(
    :mode => "lines+markers",
    :x => df2[bb, :t],
    :y => df2[bb, :k],
    :name => "0.4%, denuded",
    :line => Dict(:color => "rgb(0.72, 0.53, 0.04)", :width => 1),
)

trace4b = Dict(
    :mode => "lines+markers",
    :x => df1[aa, :t],
    :y => df1[aa, :k],
    :name => "0.4%, denuded",
    :line => Dict(:color => "rgb(0.64, 0.71, 0.8)", :width => 1),
)

layout4 = Dict(
    :margin => Dict(:l => 60, :r => 158, :t => 0, :b => 10, :pad => 4),
    :height => 90,
    :template => t,
    :xaxis => Dict(
        :side => "bottom",
        :range => [st, et],
        :ticks => "inside",
        :showticklabels => false,
        :minor => Dict(:showgrid => true, :gridcolor => "#eeeeee"),
    ),
    :yaxis => Dict(
        :title => Dict(:text => "κ (-)", :standoff => 30),
        :range => [-0.01, 0.7],
        :ticks => "outside",
        :tickvals => [0, 0.2, 0.4, 0.6],
    ),
)

panel4 =
    Plot([GenericTrace("line", trace4a), GenericTrace("line", trace4b),  GenericTrace("line", traceY)], Layout(layout4))

df1 = sub(0.8, false)
df2 = sub(0.8, true)
aa = df1[!, :k] .> 0.05
bb = df2[!, :k] .> 0.05

trace5a = Dict(
    :mode => "lines+markers",
    :x => df2[bb, :t],
    :y => df2[bb, :k],
    :name => "0.8%, denuded",
    :line => Dict(:color => "rgb(0.72, 0.53, 0.04)", :width => 1),
)

trace5b = Dict(
    :mode => "lines+markers",
    :x => df1[aa, :t],
    :y => df1[aa, :k],
    :name => "0.8%, denuded",
    :line => Dict(:color => "rgb(0.64, 0.71, 0.8)", :width => 1),
)

layout5 = Dict(
    :margin => Dict(:l => 60, :r => 158, :t => 0, :b => 100, :pad => 4),
    :height => 190,
    :template => t,
    :xaxis => Dict(
        :side => "bottom",
        :ticks => "outside",
        :range => [st, et],
        :minor => Dict(:showgrid => true, :gridcolor => "#eeeeee"),
    ),
    :yaxis => Dict(
        :title => Dict(:text => "κ (-)", :standoff => 30),
        :range => [0, 0.7],
        :ticks => "outside",
        :tickvals => [0, 0.2, 0.4, 0.6],
        :zeroline => true
    ),
 
)

panel5 =
    Plot([GenericTrace("scatter", trace5a), GenericTrace("line", trace5b), GenericTrace("line", traceY)], Layout(layout5))

to_html("kappa.html", [panel1, panel2, panel3, panel4, panel5]; autoreload = false, displayModeBar = false)

:DONE

# function comp(ss, c1, c2)
#     df1 = sub(ss, false)
#     df2 = sub(ss, true)

#     p = plot(df1[!, :t], df1[!, :k], ylim = [0,1], label = "undenuded ss = $(ss)%", ylabel = "κ (-)", legend=:outertopright, color = c1)
#     p = plot!(df2[!, :t], df2[!, :k], label = "denuded ss = $(ss)%", color = c2, left_margin = 30px, right_margin = 20px, size = (600,200))

#     return p
# end

# p00 = heatmap(data.tf, reverse(data.diameter_mobility_midpoints), reverse(data.dN_dlog_Dp_DMA_count_2; dims = 1) , clim = (10,3000), yscale = :log10)
# p0 = plot(data.tf, data.sample_relative_humidity)
# p1 = comp(0.4, :steelblue3, :darkgoldenrod)
# plot(p00,p0,p1, layout = grid(3,1), size = (600,300))
# savefig(plot(p1, size = (700,200)), "p1.pdf")
# p2 = comp(0.6, :steelblue3, :darkgoldenrod)
# p3 = comp(0.2, :steelblue3, :darkgoldenrod)
# plot(p1, p2, p3, layout = grid(3,1), size = (600, 400))

# df1 = sub(0.2, false)
# df2 = sub(0.2, true)

# df3 = sub(0.4, false)
# df4 = sub(0.4, true)

# df5 = sub(0.8, false)
# df6 = sub(0.8, true)

# 
# ndata = Dict(
#     ("D" => reverse(data.diameter_mobility_midpoints[ii])), 
#     ("S" => reverse(data.dN_dlog_Dp_DMA_count_2[ii,:]; dims = 1)'),
#     ("t" =>  data.tf), 
#     ("RH" => data.sample_relative_humidity),
#     ("k2dt" => df2[!,:t]), ("k2ut" => df1[!,:t]),
#     ("k2d" => df2[!,:k]), ("k2u" => df1[!,:k]),
#     ("k4dt" => df4[!,:t]), ("k4ut" => df3[!,:t]),
#     ("k4d" => df4[!,:k]), ("k4u" => df3[!,:k]),
#     ("k8dt" => df6[!,:t]), ("k8ut" => df5[!,:t]),
#     ("k8d" => df6[!,:k]), ("k8u" => df5[!,:k])
# )
# jdata = JSON.json(ndata)

# open("data.js", "w") do file
#     write(file, "const x = ")
#     JSON.print(file, jdata)
# end