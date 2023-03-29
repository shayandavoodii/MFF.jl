using Plots
using StatsPlots

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

"""
    fix_dates!(df::DataFrame, dates::Vector{Date})

Fix date related column in `df` inplace by changing its frequency to daily.

# Arguments
- `df::DataFrame`: DataFrame object.
- `dates::Vector{Date}`: Vector of dates to be used as the new date column.

# Example
```julia
julia> df = DataFrame(col1=[1, 2, 3, 4, 5], col2=["a", "b", "c", "d", "e"])
5×2 DataFrame
 Row │ col1   col2
     │ Int64  String
─────┼───────────────
   1 │     1  a
   2 │     2  b
   3 │     3  c
   4 │     4  d
   5 │     5  e

julia> dates = collect(Date("2020-01-10"):Day(2):Date("2020-01-19"))
5-element Vector{Date}:
2020-01-10
2020-01-12
2020-01-14
2020-01-16
2020-01-18

julia> fix_dates!(df, dates);

julia> df
5×3 DataFrame
 Row │ date        col1   col2
     │ Date        Int64  String
─────┼───────────────────────────
   1 │ 2020-01-10      1  a
   2 │ 2020-01-11      2  b
   3 │ 2020-01-12      3  c
   4 │ 2020-01-13      4  d
   5 │ 2020-01-14      5  e
```
"""
function fix_dates!(df::DataFrame, dates::Vector{Date})
  firstdate = first(dates)
  enddate = (nrow(df)*Day(1))+firstdate-Day(1)
  rngdate = Date(firstdate):Day(1):enddate
  insertcols!(df, 1, :date => rngdate)
end

function check_prprty(val, prprty)
  isequal(val, nothing) && error(
    """property ($prprty) is not valid or doesn't exist. Valid properties are:
    \"timestamp", \"open", \"high", \"low", \"close", \"adjclose", \"vol". """
  )
end

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

function plot_data(df::Vector, title::String, stock::String; kwargs::NamedTuple=PLOT_KWARGS)
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
