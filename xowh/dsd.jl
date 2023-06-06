using CSV
using DataFrames
using Plotly
using PlotlyExtras

df = CSV.read("droplet_dist_up.txt", DataFrame)
dfl = CSV.read("droplet_dist_up_lb.txt", DataFrame)
dfu = CSV.read("droplet_dist_up_ub.txt", DataFrame)

df1 = CSV.read("droplet_dist_lo.txt", DataFrame)
dfl1 = CSV.read("droplet_dist_lo_lb.txt", DataFrame)
dfu1 = CSV.read("droplet_dist_lo_ub.txt", DataFrame)


t = get_layout("default.json")

trace1 = Dict(
    :mode => "markers",
    :x => df[!,:D],
    :y => df[!,:dNdD],
    :error_y => Dict(:array => dfu[!,:dNdD].-df[!,:dNdD], :arrayminus => df[!,:dNdD].-dfl[!,:dNdD], :type => "data", :thickness => 1),
    :name => "Spectrum 1",
    :line => Dict(:color => "rgb(0.72, 0.53, 0.04)", :width => 0.1),
    :showlegend => true,
    :visible => "legendonly"
)

trace2 = Dict(
    :mode => "markers",
    :x => df1[!,:D],
    :y => df1[!,:dNdD],
    :error_y => Dict(:array => dfu1[!,:dNdD].-df1[!,:dNdD], :arrayminus => df1[!,:dNdD].-dfl1[!,:dNdD], :type => "data", :thickness => 1),
    :name => "Spectrum 2",
    :line => Dict(:color => "rgb(0.64, 0.71, 0.8)", :width => 0.1),
    :showlegend => true,
    :visible => "legendonly"
)


layout1 = Dict{Symbol,Any}(
    :title => "",
    :font => Dict(:size => 12),
    :margin => Dict(:l => 60, :r => 158, :t => 10, :b => 50, :pad => 4),
    :template => t,
    :xaxis => Dict(:range => [0, 50], :showticklabels => true, :ticks => "",),
    :yaxis => Dict(
        # :type => "log",
        # :tickvals => [30, 50, 100, 200],
        # :title => Dict(:text => "D (nm)", :standoff => 9),
        :range => [0, 30]
    ),
    :height => 360,
    :showlegend => true,

)

panel1 = Plot([GenericTrace("line", trace1),GenericTrace("line", trace2)], Layout(layout1))

to_html("dsd.html", [panel1]; autoreload = false, displayModeBar = false)