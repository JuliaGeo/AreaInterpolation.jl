using ArealInterpolation
using Documenter

DocMeta.setdocmeta!(ArealInterpolation, :DocTestSetup, :(using ArealInterpolation); recursive=true)

makedocs(;
    modules=[ArealInterpolation],
    authors="Anshul Singhvi <anshulsinghvi@gmail.com> and contributors",
    sitename="ArealInterpolation.jl",
    format=Documenter.HTML(;
        canonical="https://JuliaGeo.github.io/ArealInterpolation.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaGeo/ArealInterpolation.jl",
    devbranch="main",
)
