push!(LOAD_PATH,"../src/")
using Documenter
using MFF

DocMeta.setdocmeta!(MFF, :DocTestSetup, :(using MFF); recursive=true)

makedocs(
    modules = [MFF],
    authors="Shayan Davoodi <sh0davoodi@gmail.com>",
    format = Documenter.HTML(
        canonical = "https://shayandavoodii.github.io/MFF/",
        prettyurls = get(ENV, "CI", nothing) == "true"
    ),
    pages = [
        "Home" => "index.md",
        ],
    sitename = "MFF",
)

deploydocs(
    repo="github.com/shayandavoodii/MFF.git",
    devbranch = "master"
)
