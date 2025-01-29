module MFFCSV

using CSV
using DataFrames
using MFF

# COV_EXCL_START
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
# COV_EXCL_STOP

end # module
