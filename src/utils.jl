const properties = ("timestamp", "open", "high", "low", "close", "adjclose", "vol")

function plot_data end

"""
    gs(stocks::AbstractVector{String}, startdt::String, enddt::String, path::String; rng::Union{Nothing, String}=nothing, market::String="", prefix::String="", suffix::String="")

Get "adjusted close", "high", "low", "open", and "volume" data for a set of stocks and save them to a csv file.

!!! note
    You should import the `CSV` and `DataFrames` packages before using this function.

# Arguments
- `stocks::AbstractVector{String}`: A vector of stock tickers.
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
function gs end

"""
    checklen!(vec::AbstractVector{<:AbstractVector})

Check the length of each inner vector in the `vec`, and remove the vectors with different \
lengths. Note that this function may alter the `vec` in-place.

# Arguments
- `vec::AbstractVector{<:AbstractVector}`: A vector of vectors.

# Returns
- `::Union{Nothing, Vector{Int}}`: The indices of the inner vectors that have different \
lengths. If all the inner vectors have the same length, return `nothing`.

# Example
```julia
julia> b = [
       [1,2,1,2],
       [2,4,5],
       [2,2,3,4],
       [1,2]
       ];

julia> MFF.checklen!(b)
4-element BitVector:
 0
 1
 0
 1
```
"""
function checklen!(vec::AbstractVector{<:AbstractVector})
  lengths = length.(vec)
  all(lengths .== lengths[1]) && return nothing
  _, maxlen = frequency(lengths)
  idxdel = lengths .!= maxlen
  deleteat!(vec, idxdel)
  return idxdel
end

"""
    frequency(vec::AbstractVector)

Return the frequency of each unique element in the `vec` and the element with the highest \
frequency.

# Arguments
- `vec::AbstractVector`: A vector of elements.

# Returns
- `::Tuple{Dict{Int64, Int64}, Int64}`: A tuple of a dictionary of the frequency of each \
unique element and the element with the highest frequency.

# Example
```julia
julia> b = [
       [1,2,1,2],
       [2,4,5],
       [2,2,3,4],
       [1,2]
       ]
       lengths = length.(b)
4-element Vector{Int64}:
 4
 3
 4
 2

julia> MFF.frequency(lengths)
(Dict(4 => 2, 2 => 1, 3 => 1), 4)
```
"""
function frequency(vec::AbstractVector)
  uniques = unique(vec)
  counts = sum.(x->sum(x.==vec), uniques)
  max_ = uniques[argmax(counts)]
  return Dict(zip(uniques, counts)), max_
end
