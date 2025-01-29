"""
    get_data(
      ::Val{:df},
      stock::String,
      startdt::String,
      enddt::String;
      prprty::String="adjclose",
      rng::Nothing=nothing,
      fixdt::Bool=true,
      kwargs::NamedTuple=(;title=prprty))::DataFrame
    )

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
  ::Val{:vec},
  stock::String,
  startdt::String,
  enddt::String;
  prprty::String="adjclose",
  rng::String="1d",
  plot::Bool=false,
  kwargs::NamedTuple=(;title=prprty)
)

  Date(enddt)>Date(startdt) || throw(ArgumentError("The end date ($enddt) isn't greater /
  than start date ($startdt))"))
  prprty ∉ properties && throw(ArgumentError(
  "property ($prprty) is not valid or doesn't exist. Valid properties are: 'timestamp', /
  'open', 'high', 'low', 'close', 'adjclose', 'vol'. "))
  dict = get_prices(stock, startdt=startdt, enddt=enddt, range=rng)
  val = get(dict, prprty, nothing)
  isnothing(val) && return nothing
  plot && plot_data(val, prprty, stock, kwargs=kwargs)
  return val
end

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

  Date(enddt)>Date(startdt) || throw(ArgumentError("The end date ($enddt) isn't greater /
  than start date ($startdt))"))
  prprty ∉ properties && throw(ArgumentError(
  "property ($prprty) is not valid or doesn't exist. Valid properties are: 'timestamp', /
  'open', 'high', 'low', 'close', 'adjclose', 'vol'. "))
  vec_of_dicts = get_prices.(stock, startdt=startdt, enddt=enddt, range=rng)
  vec_of_vecs = get.(vec_of_dicts, prprty, nothing)
  all(isnothing, vec_of_vecs) && return nothing
  redundantidx = findall(isnothing, vec_of_vecs)
  deleteat!(stock, redundantidx)
  filter!(!isnothing, vec_of_vecs)
  mat = stack(vec_of_vecs, dims=2)
  plot && plot_data(mat, prprty, stock, kwargs=kwargs)
  return mat
end
