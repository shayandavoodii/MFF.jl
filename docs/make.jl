using Documenter
using MFF

DocMeta.setdocmeta!(MFF, :DocTestSetup, :(using MFF))

makedocs(;
    format = Documenter.HTML(
        canonical = "https://shayandavoodii.github.io/MFF/",
        edit_link = "https://github.com/shayandavoodii/MFF/gh-pages/docs/src/",
    ),
    pages = [
        "Home" => "index.md",
        ],
    sitename = "MFF",
)
