using ArealInterpolation
using Documenter, DocumenterVitepress

DocMeta.setdocmeta!(ArealInterpolation, :DocTestSetup, :(using ArealInterpolation); recursive=true)

makedocs(;
    modules=[ArealInterpolation],
    authors="Anshul Singhvi <anshulsinghvi@gmail.com> and contributors",
    sitename="ArealInterpolation.jl",
    format=DocumenterVitepress.MarkdownVitepress(;
        repo = "https://github.com/JuliaGeo/ArealInterpolation.jl",
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaGeo/ArealInterpolation.jl",
    devbranch="main",
)
