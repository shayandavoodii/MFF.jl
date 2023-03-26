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
  rng::Nothing=nothing,
  fixdt::Bool=true,
  plot::Bool=false
)::DataFrame

  @assert Date(enddt)>Date(startdt) "The end date ($enddt) isn't greater than start date ($startdt))"
  isnothing(rng) ? rng="1d" : rng=rng
  dict = get_prices(stock, startdt=startdt, enddt=enddt, range=rng)
  val = get(dict, prprty, nothing)
  check_prprty(val, prprty)
  datetime = get(dict, "timestamp", nothing)
  date = Date.(datetime)
  dataframe = DataFrame([val], [stock])
  fixdt && fix_dates!(dataframe, date)
  fixdt || insertcols!(dataframe, 1, :date => date)
  plot && plot_data(dataframe, prprty)
  return dataframe
end;

function get_data(
  ::Val{:vec},
  stock::String,
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::Nothing=nothing,
  plot::Bool=false
)::Vector{Float64}

  @assert Date(enddt)>Date(startdt) "The end date ($enddt) isn't greater than start date ($startdt))"
  isnothing(rng) ? rng="1d" : rng=rng
  dict = get_prices(stock, startdt=startdt, enddt=enddt, range=rng)
  val = get(dict, prprty, nothing)
  check_prprty(val, prprty)
  plot && plot_data(val, prprty, stock)
  return val
end;

function get_data(
  ::Val{:df},
  stock::Vector{String},
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::Nothing=nothing,
  fixdt::Bool=true,
  plot::Bool=false
)::DataFrame

  @assert Date(enddt)>Date(startdt) "The end date ($enddt) isn't greater than start date ($startdt))"
  isnothing(rng) ? rng="1d" : rng=rng
  vec_of_dicts = get_prices.(stock, startdt=startdt, enddt=enddt, range=rng)
  vec_of_vecs = get.(vec_of_dicts, prprty, nothing)
  check_prprty.(vec_of_vecs, prprty)
  dataframe = DataFrame(vec_of_vecs, stock)
  datetime = get(vec_of_dicts[1], "timestamp", nothing)
  date = Date.(datetime)
  fixdt && fix_dates!(dataframe, date)
  fixdt || insertcols!(dataframe, 1, :date => date)
  plot && plot_data(dataframe, prprty)
  return dataframe
end;

function get_data(
  ::Val{:vec},
  stock::Vector{String},
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::Nothing=nothing,
  fixdt::Bool=true,
  plot::Bool=false
)::Matrix{Float64}

  @assert Date(enddt)>Date(startdt) "The end date ($enddt) isn't greater than start date ($startdt))"
  isnothing(rng) ? rng="1d" : rng=rng
  vec_of_dicts = get_prices.(stock, startdt=startdt, enddt=enddt, range=rng)
  vec_of_vecs = get.(vec_of_dicts, prprty, nothing)
  check_prprty.(vec_of_vecs, prprty)
  mat = reduce(hcat, vec_of_vecs)
  plot && plot_data(mat, prprty, stock)
  return mat
end;
