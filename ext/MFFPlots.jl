module MFFFrames

using Plots
using StatsPlots
using MFF
# COV_EXCL_START
const PLOT_KWARGS = (;
  legend=:outerright,
  legend_title="Stocks",
  ylabel="Value",
  title="",
  size=(1000, 600),
  left_margin=5Plots.mm,
  bottom_margin=5Plots.mm,
  dpi=300,
  marker=:none,
)

function plot_data(df::DataFrame, title::String; kwargs::NamedTuple=PLOT_KWARGS)
  n_stocks = ncol(df)-1
  dates = @view df[!, :date]
  kwargs = merge((;title=title), kwargs)
  kwargs = merge(PLOT_KWARGS, kwargs)
  p = @df @view(df[!, 2:end]) plot(
    dates, cols(1:n_stocks),
    legend=kwargs.legend,
    legend_title=kwargs.legend_title,
    ylabel=kwargs.ylabel,
    title=kwargs.title*" values",
    size=kwargs.size,
    left_margin=kwargs.left_margin,
    bottom_margin=kwargs.bottom_margin,
    dpi=kwargs.dpi,
    marker=kwargs.marker,
  )
  display(p)
end

function plot_data(
  df::Matrix,
  title::String,
  stocks::Vector{String};
  kwargs::NamedTuple=PLOT_KWARGS
)
  kwargs = merge((;title=title), kwargs)
  kwargs = merge(PLOT_KWARGS, kwargs)
  p = plot(
    df,
    legend=kwargs.legend,
    legend_title=kwargs.legend_title,
    label=permutedims(stocks),
    ylabel=kwargs.ylabel,
    title=kwargs.title*" values",
    size=kwargs.size,
    left_margin=kwargs.left_margin,
    bottom_margin=kwargs.bottom_margin,
    dpi=kwargs.dpi,
    marker=kwargs.marker,
  )
  display(p)
end

function MFF.plot_data(df::Vector, title::String, stock::String; kwargs::NamedTuple=PLOT_KWARGS)
  kwargs = merge((;title=title), kwargs)
  kwargs = merge(PLOT_KWARGS, kwargs)
  p = plot(
    df,
    legend=kwargs.legend,
    legend_title=kwargs.legend_title,
    label=stock,
    ylabel=kwargs.ylabel,
    title=kwargs.title*" values",
    size=kwargs.size,
    left_margin=kwargs.left_margin,
    bottom_margin=kwargs.bottom_margin,
    dpi=kwargs.dpi,
    marker=kwargs.marker,
  )
  display(p)
end
# COV_EXCL_STOP
end # module
