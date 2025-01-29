const properties = ("timestamp", "open", "high", "low", "close", "adjclose", "vol")

function plot_data end

"""
    gs(stocks::Vector{String}, startdt::String, enddt::String, path::String; rng::Union{Nothing, String}=nothing, market::String="", prefix::String="", suffix::String="")

Get "adjusted close", "high", "low", "open", and "volume" data for a set of stocks and save them to a csv file.

!!! note
    You should import the `CSV` and `DataFrames` packages before using this function.

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
function gs end
