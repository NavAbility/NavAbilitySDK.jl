using NavAbilitySDK
using Documenter

DocMeta.setdocmeta!(NavAbilitySDK, :DocTestSetup, :(using NavAbilitySDK); recursive=true)

makedocs(;
    modules=[NavAbilitySDK],
    authors="NavAbility",
    repo="https://github.com/NavAbility/NavAbilitySDK.jl/blob/{commit}{path}#{line}",
    sitename="NavAbilitySDK.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://NavAbility.github.io/NavAbilitySDK.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/NavAbility/NavAbilitySDK.jl",
    devbranch="main",
)
