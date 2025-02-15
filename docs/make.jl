push!(LOAD_PATH,"../src/")
using Documenter
using MFF

DocMeta.setdocmeta!(MFF, :DocTestSetup, :(using MFF); recursive=true)

makedocs(
    modules = [MFF],
    authors="Shayan Davoodi <sh0davoodi@gmail.com>",
    format = Documenter.HTML(
        canonical = "https://shayandavoodii.github.io/MFF.jl/",
        prettyurls = get(ENV, "CI", nothing) == "true"
    ),
    pages = [
        "Home" => "index.md",
        "API" => [
          "Functions" => "functions.md"
        ],
    ],
    sitename = "MFF.jl",
)

deploydocs(
    repo="github.com/shayandavoodii/MFF.jl.git",
    devbranch = "master",
    push_preview = true
)
