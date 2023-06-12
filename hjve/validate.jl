# Cross-validation script to compare against Jeff Snider implementation

using CSV
using DataFrames
using Plotly
using PlotlyExtras

df = CSV.read("sb2001_x_50_10_15_.csv", DataFrame)

t = get_layout("default.json")

trace1 = Dict(
    :mode => "lines",
    :x => df[!,"time [s]"]./3600,
    :y => df[!,"Lr [g cm^-3]"].*1e6,
    :name => "JRS Lr",
    :line => Dict(:color => "rgb(0.72, 0.53, 0.04)", :width => 0.5),
    :showlegend => true,
)

trace2 = Dict(
    :mode => "lines",
    :x => df[!,"time [s]"]./3600,
    :y => df[!,"Lc [g cm^-3]"].*1e6,
    :name => "JRS Lc",
    :line => Dict(:color => "rgb(0, 0.53, 0.04)", :width => 0.5),
    :showlegend => true,
)

trace3 = Dict(
    :mode => "lines",
    :x => df[!,"time [s]"]./3600,
    :y => df[!,"Nr [cm^-3]"].*1000,
    :name => "JRS Nr",
    :line => Dict(:color => "rgb(0.72, 0.53, 0.04)", :width => 0.5),
    :showlegend => true,
)


layout1 = Dict{Symbol,Any}(
    :title => "",
    :font => Dict(:size => 12),
    :margin => Dict(:l => 60, :r => 158, :t => 10, :b => 50, :pad => 4),
    :template => t,
    # :xaxis => Dict(:range => [0, 50], :showticklabels => true, :ticks => "",),
    # :yaxis => Dict(
        # :type => "log",
        # :tickvals => [30, 50, 100, 200],
        # :title => Dict(:text => "D (nm)", :standoff => 9),
        # :range => [0, 30]
    # ),
    :height => 360,
    :showlegend => true,

)

panel1 = Plot(GenericTrace("line", trace1), Layout(layout1))
panel2 = Plot(GenericTrace("line", trace2), Layout(layout1))
panel3 = Plot(GenericTrace("line", trace3), Layout(layout1))

to_html("jrs.html", [panel1, panel2, panel3]; autoreload = false, displayModeBar = false)