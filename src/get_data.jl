include("utils.jl")

"""
    get_data(::Val{:df}, stock::String, startdt::String, enddt::String; prprty::String="adjclose", rng::Nothing=nothing, fixdt::Bool=true)::DataFrame

Fetch data from Yahoo Finance and return a DataFrame.

# Arguments
- `::Val{:df}`: Return a DataFrame.
- `stock::String`: The stock ticker.
- `startdt::String`: The start date. The format is "YYYY-MM-DD".
- `enddt::String`: The end date. The format is "YYYY-MM-DD".
- `prprty::String="adjclose"`: The property to fetch. The other options are `"open"`, `"high"`, `"low"`, `"close"`, `"vol"`, `"timestamp"`.
- `rng::Nothing=nothing`: The range of the data. The other options are `"1d"`, `"5d"`, `"1mo"`, `"3mo"`, `"6mo"`, `"1y"`, `"2y"`, `"5y"`, `"10y"`.
- `fixdt::Bool=true`: Fix the dates. If `true`, the dates will be fixed to the range of the data. If `false`, the dates will be the dates of the data.
- `plot::Bool=false`: Plot the data.
- `kwargs::NamedTuple=(;title=prprty)`: The keyword arguments for the `plot` function. The default title is the property. The other options are `legend`, `legend_title`, `ylabel`, `title`, `size`, `left_margin`, `bottom_margin`, `dpi`, and `marker`.

# Returns
- `::DataFrame`: The DataFrame of the data.

# Methods
- `get_data(::Val{:df}, stock::String, startdt::String, enddt::String; prprty::String="adjclose", rng::Nothing=nothing, fixdt::Bool=true)::DataFrame`
- `get_data(::Val{:vec}, stock::String, startdt::String, enddt::String; prprty::String="adjclose", rng::Nothing=nothing)::Vector{Vector}`

# Examples
```julia
julia> using MFF

julia> get_data(Val(:df), "AAPL", "2020-01-10", "2020-01-15", fixdt=false)
3×2 DataFrame
 Row │ date        AAPL
     │ Date        Float64
─────┼─────────────────────
   1 │ 2020-01-10  75.89
   2 │ 2020-01-13  77.5113
   3 │ 2020-01-14  76.4646

julia> get_data(Val(:df), "AAPL", "2020-01-10", "2020-01-15")
3×2 DataFrame
 Row │ date        AAPL
     │ Date        Float64
─────┼─────────────────────
   1 │ 2020-01-10  75.89
   2 │ 2020-01-11  77.5113
   3 │ 2020-01-12  76.4646

julia> get_data(Val(:df), "AAPL", "2020-01-10", "2020-01-15", prprty="open")
3×2 DataFrame
 Row │ date        AAPL
     │ Date        Float64
─────┼─────────────────────
   1 │ 2020-01-10  75.956
   2 │ 2020-01-11  76.2103
   3 │ 2020-01-12  77.4477

julia> get_data(Val(:df), ["AAPL", "MSFT"], "2020-01-10", "2020-01-15", prprty="high")
3×3 DataFrame
Row │ date        AAPL     MSFT
    │ Date        Float64  Float64
─────┼──────────────────────────────
  1 │ 2020-01-10  76.4622  158.283
  2 │ 2020-01-11  77.5382  158.37
  3 │ 2020-01-12  77.6605  158.652

julia> get_data(Val(:vec), ["AAPL", "MSFT"], "2020-01-10", "2020-01-15", prprty="high")
3×2 Matrix{Float64}:
76.4622  158.283
77.5382  158.37
77.6605  158.652
```
"""
function get_data(
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
  dict = get_prices(stock, startdt=startdt, enddt=enddt, range=rng)
  val = get(dict, prprty, nothing)
  check_prprty(val, prprty)
  datetime = get(dict, "timestamp", nothing)
  date = Date.(datetime)
  dataframe = DataFrame([val], [stock])
  fixdt && fix_dates!(dataframe, date)
  fixdt || insertcols!(dataframe, 1, :date => date)
  plot && plot_data(dataframe, prprty, kwargs=kwargs)
  return dataframe
end;

function get_data(
  ::Val{:vec},
  stock::String,
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::String="1d",
  plot::Bool=false,
  kwargs::NamedTuple=(;title=prprty)
)::Vector{Float64}

  @assert Date(enddt)>Date(startdt) "The end date ($enddt) isn't greater than start date ($startdt))"
  dict = get_prices(stock, startdt=startdt, enddt=enddt, range=rng)
  val = get(dict, prprty, nothing)
  check_prprty(val, prprty)
  plot && plot_data(val, prprty, stock, kwargs=kwargs)
  return val
end;

function get_data(
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
  vec_of_dicts = get_prices.(stock, startdt=startdt, enddt=enddt, range=rng)
  vec_of_vecs = get.(vec_of_dicts, prprty, nothing)
  check_prprty.(vec_of_vecs, prprty)
  dataframe = DataFrame(vec_of_vecs, stock)
  datetime = get(vec_of_dicts[1], "timestamp", nothing)
  date = Date.(datetime)
  fixdt && fix_dates!(dataframe, date)
  fixdt || insertcols!(dataframe, 1, :date => date)
  plot && plot_data(dataframe, prprty, kwargs=kwargs)
  return dataframe
end;

function get_data(
  ::Val{:vec},
  stock::Vector{String},
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::String="1d",
  plot::Bool=false,
  kwargs::NamedTuple=(;title=prprty)
)::Matrix{Float64}

  @assert Date(enddt)>Date(startdt) "The end date ($enddt) isn't greater than start date ($startdt))"
  vec_of_dicts = get_prices.(stock, startdt=startdt, enddt=enddt, range=rng)
  vec_of_vecs = get.(vec_of_dicts, prprty, nothing)
  check_prprty.(vec_of_vecs, prprty)
  mat = reduce(hcat, vec_of_vecs)
  plot && plot_data(mat, prprty, stock, kwargs=kwargs)
  return mat
end;

"""
    gs(stocks::Vector{String}, startdt::String, enddt::String, path::String; rng::Union{Nothing, String}=nothing, market::String="", prefix::String="", suffix::String="")

Get "adjusted close", "high", "low", "open", and "volume" data for a set of stocks and save them to a csv file.

# Arguments
- `stocks::Vector{String}`: A vector of stock tickers.
- `startdt::String`: The start date of the data.
- `enddt::String`: The end date of the data.
- `path::String`: The path to save the csv file.
- `rng::String="1d"`: The range of the data.
- `market::String=""`: The market of the stocks.
- `prefix::String=""`: The prefix of the csv file name.
- `suffix::String=""`: The suffix of the csv file name.

# Example
```julia
julia> gs(["AAPL", "MSFT"], "2020-01-01", "2020-01-31", pwd())
Saved close data to <PATH>
Saved high data to <PATH>
Saved low data to <PATH>
Saved open data to <PATH>
Saved volume data to <PATH>
Saved dates data to <PATH>
```
"""
function gs(
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
  close = get_data(Val(:df), stocks, startdt, enddt, rng=rng, fixdt=true)
  high = get_data(Val(:df), stocks, startdt, enddt, rng=rng, prprty="high", fixdt=true)
  low = get_data(Val(:df), stocks, startdt, enddt, rng=rng, prprty="low", fixdt=true)
  open = get_data(Val(:df), stocks, startdt, enddt, rng=rng, prprty="open", fixdt=true)
  volume = get_data(Val(:df), stocks, startdt, enddt, rng=rng, prprty="vol", fixdt=true)
  dates = get_data(Val(:df), first(stocks), startdt, enddt, rng=rng, prprty="timestamp", fixdt=false)
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
end;
