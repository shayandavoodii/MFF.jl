module MFFFrames

using DataFrames
using Dates
using MFF

function MFF.get_data(
  ::Val{:df},
  stock::String,
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::String="1d",
  fixdt::Bool=false,
  plot::Bool=false,
  kwargs::NamedTuple=(;title=prprty)
)

  Date(enddt)>Date(startdt) || throw(ArgumentError("The end date ($enddt) isn't greater /
  than start date ($startdt))"))
  prprty ∉ MFF.properties && throw(ArgumentError(
  "property ($prprty) is not valid or doesn't exist. Valid properties are: 'timestamp', /
  'open', 'high', 'low', 'close', 'adjclose', 'vol'. "))
  dict = MFF.get_prices(stock, startdt=startdt, enddt=enddt, range=rng)
  val = get(dict, prprty, nothing)
  isnothing(val) && return nothing
  datetime = get(dict, "timestamp", nothing)
  isnothing(datetime) && @warn "'timestamp' key isn't available for $stock" && return nothing
  date = Date.(datetime)
  dataframe = DataFrame([val], [stock])
  fixdt && fix_dates!(dataframe, date)
  fixdt || insertcols!(dataframe, 1, :date => date)
  plot && plot_data(dataframe, prprty, kwargs=kwargs)
  return dataframe
end

function MFF.get_data!(
  ::Val{:df},
  stock::Vector{String},
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::String="1d",
  fixdt::Bool=false,
  plot::Bool=false,
  kwargs::NamedTuple=(;title=prprty)
)
  Date(enddt)>Date(startdt) || throw(ArgumentError("The end date ($enddt) isn't greater /
  than start date ($startdt))"))
  prprty ∉ MFF.properties && throw(ArgumentError(
  "property ($prprty) is not valid or doesn't exist. Valid properties are: 'timestamp', /
  'open', 'high', 'low', 'close', 'adjclose', 'vol'. "))
  vec_of_dicts = MFF.get_prices.(stock, startdt=startdt, enddt=enddt, range=rng)
  vec_of_vecs = get.(vec_of_dicts, prprty, nothing)
  all(isnothing, vec_of_vecs) && return nothing
  redundantidx = findall(isnothing, vec_of_vecs)
  deleteat!(stock, redundantidx)
  deleteat!(vec_of_dicts, redundantidx)
  filter!(!isnothing, vec_of_vecs)
  dataframe = DataFrame(vec_of_vecs, stock)
  datetime = get(vec_of_dicts[1], "timestamp", nothing)
  date = Date.(datetime)
  fixdt && fix_dates!(dataframe, date)
  fixdt || insertcols!(dataframe, 1, :date => date)
  plot && plot_data(dataframe, prprty, kwargs=kwargs)
  return dataframe
end

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

end # module
