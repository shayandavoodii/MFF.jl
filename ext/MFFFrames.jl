module MFFFrames

using DataFrames
using Dates
using CSV
using MFF

function MFF.get_data(
  ::Val{:df},
  stock::String,
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::String="1d",
  fixdt::Bool=true,
  plot::Bool=false,
  kwargs::NamedTuple=(;title=prprty)
)::DataFrame

  @assert Date(enddt)>Date(startdt) "The end date ($enddt) isn't greater than start date ($startdt))"
  dict = MFF.get_prices(stock, startdt=startdt, enddt=enddt, range=rng)
  val = get(dict, prprty, nothing)
  MFF.check_prprty(val, prprty)
  datetime = get(dict, "timestamp", nothing)
  date = Date.(datetime)
  dataframe = DataFrame([val], [stock])
  fixdt && fix_dates!(dataframe, date)
  fixdt || insertcols!(dataframe, 1, :date => date)
  plot && plot_data(dataframe, prprty, kwargs=kwargs)
  return dataframe
end

function MFF.get_data(
  ::Val{:df},
  stock::Vector{String},
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::String="1d",
  fixdt::Bool=true,
  plot::Bool=false,
  kwargs::NamedTuple=(;title=prprty)
)::DataFrame

  @assert Date(enddt)>Date(startdt) "The end date ($enddt) isn't greater than start date ($startdt))"
  vec_of_dicts = MFF.get_prices.(stock, startdt=startdt, enddt=enddt, range=rng)
  vec_of_vecs = get.(vec_of_dicts, prprty, nothing)
  MFF.check_prprty.(vec_of_vecs, prprty)
  dataframe = DataFrame(vec_of_vecs, stock)
  datetime = get(vec_of_dicts[1], "timestamp", nothing)
  date = Date.(datetime)
  fixdt && fix_dates!(dataframe, date)
  fixdt || insertcols!(dataframe, 1, :date => date)
  plot && plot_data(dataframe, prprty, kwargs=kwargs)
  return dataframe
end

function MFF.gs(
  stocks::Vector{String},
  startdt::String,
  enddt::String,
  path::String;
  rng::String="1d",
  market::String="",
  prefix::String="",
  suffix::String="",
)
  ispath(path) || throw(ArgumentError("The path ($path) doesn't exist"))
  close = MFF.get_data(Val(:df), stocks, startdt, enddt, rng=rng, fixdt=true)
  high = MFF.get_data(Val(:df), stocks, startdt, enddt, rng=rng, prprty="high", fixdt=true)
  low = MFF.get_data(Val(:df), stocks, startdt, enddt, rng=rng, prprty="low", fixdt=true)
  open = MFF.get_data(Val(:df), stocks, startdt, enddt, rng=rng, prprty="open", fixdt=true)
  volume = MFF.get_data(Val(:df), stocks, startdt, enddt, rng=rng, prprty="vol", fixdt=true)
  dates = MFF.get_data(Val(:df), first(stocks), startdt, enddt, rng=rng, prprty="timestamp", fixdt=false)
  select!(dates, 1)

  CSV.write(joinpath(path, prefix*"close_$(market)"*suffix*".csv"), close)
  println("Saved close data to $(joinpath(path, prefix*"close_$(market)"*suffix*".csv"))")
  CSV.write(joinpath(path, prefix*"high_$(market)"*suffix*".csv"), high)
  println("Saved high data to $(joinpath(path, prefix*"high_$(market)"*suffix*".csv"))")
  CSV.write(joinpath(path, prefix*"low_$(market)"*suffix*".csv"), low)
  println("Saved low data to $(joinpath(path, prefix*"low_$(market)"*suffix*".csv"))")
  CSV.write(joinpath(path, prefix*"open_$(market)"*suffix*".csv"), open)
  println("Saved open data to $(joinpath(path, prefix*"open_$(market)"*suffix*".csv"))")
  CSV.write(joinpath(path, prefix*"volume_$(market)"*suffix*".csv"), volume)
  println("Saved volume data to $(joinpath(path, prefix*"volume_$(market)"*suffix*".csv"))")
  CSV.write(joinpath(path, prefix*"dates_$(market)"*suffix*".csv"), dates)
  println("Saved dates data to $(joinpath(path, prefix*"dates_$(market)"*suffix*".csv"))")
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

end
