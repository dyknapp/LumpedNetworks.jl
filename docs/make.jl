using LumpedNetworks
using Documenter

DocMeta.setdocmeta!(LumpedNetworks, :DocTestSetup, :(using LumpedNetworks); recursive=true)

makedocs(;
    modules=[LumpedNetworks],
    authors="Daniel Knapp <daniel.y.knapp@gmail.com> and contributors",
    sitename="LumpedNetworks.jl",
    format=Documenter.HTML(;
        canonical="https://dyknapp.github.io/LumpedNetworks.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/dyknapp/LumpedNetworks.jl",
    devbranch="main",
)
