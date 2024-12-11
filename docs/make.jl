using LocalCustoms
using Documenter

DocMeta.setdocmeta!(LocalCustoms, :DocTestSetup, :(using LocalCustoms); recursive=true)

makedocs(;
    modules=[LocalCustoms],
    authors="Kyle Sherbert <kyle.sherbert@vt.edu> and contributors",
    sitename="LocalCustoms.jl",
    format=Documenter.HTML(;
        canonical="https://kmsherbertvt.github.io/LocalCustoms.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/kmsherbertvt/LocalCustoms.jl",
    devbranch="main",
)
