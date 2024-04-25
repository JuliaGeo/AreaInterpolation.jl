using AreaInterpolation
using Documenter, DocumenterVitepress

DocMeta.setdocmeta!(AreaInterpolation, :DocTestSetup, :(using AreaInterpolation); recursive=true)

makedocs(;
    modules=[AreaInterpolation],
    authors="Anshul Singhvi <anshulsinghvi@gmail.com> and contributors",
    sitename="AreaInterpolation.jl",
    format=DocumenterVitepress.MarkdownVitepress(;
        repo = "https://github.com/JuliaGeo/AreaInterpolation.jl",
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/JuliaGeo/AreaInterpolation.jl",
    devbranch="main",
)
