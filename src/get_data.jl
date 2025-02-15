"""
    get_data(
      ::Val{:df},
      stock::String,
      startdt::String,
      enddt::String;
      prprty::String="adjclose",
      rng::String="1d",
      plot::Bool=false,
      kwargs::NamedTuple=(;title=prprty)
    )

Fetch data from Yahoo Finance and return a DataFrame.

!!! note
    You should import the `DataFrames` package if you would like to get the result as a DataFrame.

# Arguments
- `::Val{:df}`: Return a DataFrame.
- `stock::String`: The stock ticker.
- `startdt::String`: The start date. The format is "YYYY-MM-DD".
- `enddt::String`: The end date. The format is "YYYY-MM-DD".
- `prprty::String="adjclose"`: The property to fetch. The other options are `"open"`, \
  `"high"`, `"low"`, `"close"`, `"vol"`, `"timestamp"`.
- `rng::Nothing=nothing`: The range of the data. The other options are `"1d"`, `"5d"`, \
  `"1mo"`, `"3mo"`, `"6mo"`, `"1y"`, `"2y"`, `"5y"`, `"10y"`.
- `fixdt::Bool=false`: Fix the dates. If `true`, the dates will be fixed to the range of \
  the data. If `false`, the dates will be the dates of the data.
- `plot::Bool=false`: Plot the data.
- `kwargs::NamedTuple=(;title=prprty)`: The keyword arguments for the `plot` function. The \
  default title is the property. The other options are `legend`, `legend_title`, `ylabel`, \
  `title`, `size`, `left_margin`, `bottom_margin`, `dpi`, and `marker`.

# Returns
- `Union{Vector, Nothing}`: The DataFrame of the data or `nothing`.

# Methods
- `get_data(::Val{:vec}, stock::String, startdt::String, enddt::String; prprty::String="adjclose", rng::Nothing=nothing)

# Examples
```julia
julia> using MFF, DataFrames

julia> get_data(Val(:df), "AAPL", "2020-01-10", "2020-01-15")
3×2 DataFrame
 Row │ date        AAPL
     │ Date        Float64
─────┼─────────────────────
   1 │ 2020-01-10  75.2149
   2 │ 2020-01-13  76.8218
   3 │ 2020-01-14  75.7844

julia> get_data(Val(:df), "AAPL", "2020-01-10", "2020-01-15", fixdt=true)
3×2 DataFrame
 Row │ date        AAPL
     │ Date        Float64
─────┼─────────────────────
   1 │ 2020-01-10  75.2149
   2 │ 2020-01-11  76.8218
   3 │ 2020-01-12  75.7844

julia> get_data(Val(:df), "AAPL", "2020-01-10", "2020-01-15", prprty="open")
3×2 DataFrame
 Row │ date        AAPL
     │ Date        Float64
─────┼─────────────────────
   1 │ 2020-01-10  75.2803
   2 │ 2020-01-13  75.5324
   3 │ 2020-01-14  76.7588

julia> get_data(Val(:vec), "AAPL", "2020-01-10", "2020-01-15")
3-element Vector{Float64}:
 75.2148666381836
 76.82177734375
 75.78443908691406
```
"""
function get_data(
  ::Val{:vec},
  stock::String,
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::String="1d",
  plot::Bool=false,
  kwargs::NamedTuple=(;title=prprty)
)

  Date(enddt)>Date(startdt) || throw(ArgumentError("The end date ($enddt) isn't greater \
  than start date ($startdt))"))
  prprty ∉ properties && throw(ArgumentError(
  "property ($prprty) is not valid or doesn't exist. Valid properties are: 'timestamp', \
  'open', 'high', 'low', 'close', 'adjclose', 'vol'. "))
  dict = get_prices(stock, startdt=startdt, enddt=enddt, range=rng)
  val = get(dict, prprty, nothing)
  isnothing(val) && return nothing
  plot && plot_data(val, prprty, stock, kwargs=kwargs)
  return val
end

"""
    get_data!(
      ::Val{:df},
      AbstractVector{String},
      startdt::String,
      enddt::String;
      prprty::String="adjclose",
      rng::Nothing=nothing,
      fixdt::Bool=false,
      kwargs::NamedTuple=(;title=prprty))::DataFrame
    )

Fetch data from Yahoo Finance and return a DataFrame. Alters the input vector by removing the invalid stock tickers.

!!! note
    You should import the `DataFrames` package if you would like to get the result as a DataFrame.

# Arguments
- `::Val{:df}`: Return a DataFrame.
- `AbstractVector{String}`: The stock tickers.
- `startdt::String`: The start date. The format is "YYYY-MM-DD".
- `enddt::String`: The end date. The format is "YYYY-MM-DD".
- `prprty::String="adjclose"`: The property to fetch. The other options are `"open"`, \
  `"high"`, `"low"`, `"close"`, `"vol"`, `"timestamp"`.
- `rng::Nothing=nothing`: The range of the data. The other options are `"1d"`, `"5d"`, \
  `"1mo"`, `"3mo"`, `"6mo"`, `"1y"`, `"2y"`, `"5y"`, `"10y"`.
- `fixdt::Bool=false`: Fix the dates. If `true`, the dates will be fixed to the range of \
  the data. If `false`, the dates will be the dates of the data.
- `plot::Bool=false`: Plot the data.
- `kwargs::NamedTuple=(;title=prprty)`: The keyword arguments for the `plot` function. \
  The default title is the property. The other options are `legend`, `legend_title`, \
  `ylabel`, `title`, `size`, `left_margin`, `bottom_margin`, `dpi`, and `marker`.

# Returns
- `::Union{DataFrame, Nothing}`: The DataFrame of the data or `nothing`.

# Methods
`get_data!(::Val{:vec}, AbstractVector{String}, startdt::String, enddt::String; prprty::String="adjclose", rng::Nothing=nothing)`

# Examples
```julia
julia> get_data!(Val(:df), ["AAPL", "MSFT"], "2020-01-10", "2020-01-15", prprty="high")
3×3 DataFrame
 Row │ date        AAPL     MSFT
     │ Date        Float64  Float64
─────┼──────────────────────────────
   1 │ 2020-01-10  75.782   156.118
   2 │ 2020-01-13  76.8485  156.204
   3 │ 2020-01-14  76.9696  156.481

julia> get_data!(Val(:vec), ["AAPL", "MSFT"], "2020-01-10", "2020-01-15", prprty="high")
3×2 Matrix{Float64}:
 75.782   156.118
 76.8484  156.204
 76.9696  156.481

julia> assets = ["MSFT", "Invalid"];

julia> get_data!(Val(:df), assets, "2020-01-10", "2020-01-15", prprty="high")
┌ Warning: Invalid is not a valid Symbol.
└ @ YFinance C:\\Users\\Shayan\\.julia\\packages\\YFinance\\lfXr3\\src\\Prices.jl:205
3×2 DataFrame
 Row │ date        MSFT
     │ Date        Float64
─────┼─────────────────────
   1 │ 2020-01-10  156.118
   2 │ 2020-01-13  156.204
   3 │ 2020-01-14  156.481

julia> assets
1-element Vector{String}:
 "MSFT"
```
"""
function get_data!(
  ::Val{:vec},
  stock::AbstractVector{String},
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::String="1d",
  plot::Bool=false,
  kwargs::NamedTuple=(;title=prprty)
)

  Date(enddt)>Date(startdt) || throw(ArgumentError("The end date ($enddt) isn't greater \
  than start date ($startdt))"))
  prprty ∉ properties && throw(ArgumentError(
  "property ($prprty) is not valid or doesn't exist. Valid properties are: 'timestamp', \
  'open', 'high', 'low', 'close', 'adjclose', 'vol'."))
  vec_of_dicts = get_prices.(stock, startdt=startdt, enddt=enddt, range=rng)
  vec_of_vecs = get.(vec_of_dicts, prprty, nothing)
  all(isnothing, vec_of_vecs) && return nothing
  redundantidx = findall(isnothing, vec_of_vecs)
  deleteat!(stock, redundantidx)
  filter!(!isnothing, vec_of_vecs)
  idxinconsistent = checklen!(vec_of_vecs)
  !isnothing(idxinconsistent) && deleteat!(stock, idxinconsistent)
  mat = stack(vec_of_vecs, dims=2)
  plot && plot_data(mat, prprty, stock, kwargs=kwargs)
  return mat
end
