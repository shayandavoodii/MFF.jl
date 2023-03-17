using YFinance
using DataFrames
using Dates


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
"""
function get_data(
  ::Val{:df},
  stock::String,
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::Nothing=nothing,
  fixdt::Bool=true
)::DataFrame
  isnothing(rng) ? rng="1d" : rng=rng
  dict = get_prices(stock, startdt=startdt, enddt=enddt, range=rng)
  val = get(dict, prprty, nothing)
  isequal(val, nothing) && error("property ($prprty) is not valid or doesn't exist")
  datetime = get(dict, "timestamp", nothing)
  date = Date.(datetime)
  dataframe = DataFrame([val], [stock])
  fixdt && begin
    firstdate = first(date)
    enddate = (size(dataframe, 1)*Day(1))+firstdate-Day(1)
    rngdate = Date(firstdate):Day(1):enddate
    insertcols!(dataframe, 1, :date => rngdate)
  end
  fixdt || insertcols!(dataframe, 1, :date => date)
  return dataframe
end;

function get_data(
  ::Val{:vec},
  stock::String,
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::Nothing=nothing
)::Vector{Vector}
  isnothing(rng) ? rng="1d" : rng=rng
  dict = get_prices(stock, startdt=startdt, enddt=enddt, range=rng)
  val = get(dict, prprty, nothing)
  isequal(val, nothing) && error("property ($prprty) is not valid or doesn't exist")

  val
end;

function get_data(
  ::Val{:df},
  stock::Vector{String},
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::Nothing=nothing,
  fixdt::Bool=true
)::DataFrame
  @assert Date(enddt)>Date(startdt) "The end date ($enddt) isn't greater than start date ($startdt))"

  isnothing(rng) ? rng="1d" : rng=rng
  vec_of_dicts = get_prices.(stock, startdt=startdt, enddt=enddt, range=rng)
  vec_of_vecs = get.(vec_of_dicts, prprty, nothing)

  dataframe = DataFrame(vec_of_vecs, stock)
  datetime = get(vec_of_dicts[1], "timestamp", nothing)
  date = Date.(datetime)
  fixdt && begin
    firstdate = first(date)
    enddate = (size(dataframe, 1)*Day(1))+firstdate-Day(1)
    rngdate = Date(firstdate):Day(1):enddate
    insertcols!(dataframe, 1, :date => rngdate)
  end
  fixdt || insertcols!(dataframe, 1, :date => date)
  return dataframe
end;

function get_data(
  ::Val{:vec},
  stock::Vector{String},
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::Nothing=nothing,
  fixdt::Bool=true
)::Vector{Vector}
  @assert Date(enddt)>Date(startdt) "The end date ($enddt) isn't greater than start date ($startdt))"

  isnothing(rng) ? rng="1d" : rng=rng
  vec_of_dicts = get_prices.(stock, startdt=startdt, enddt=enddt, range=rng)
  get.(vec_of_dicts, prprty, nothing)
end;
