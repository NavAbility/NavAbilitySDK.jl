using NavAbilitySDK
using Documenter

import NavAbilitySDK: ScatterAlignPose2, Pose2AprilTag4Corners
import NavAbilitySDK: ZInferenceType
# Prior, PriorPose2, LinearRelative, Point2Point2Range, PriorPose2, PriorPoint2

const NvaSDK = NavAbilitySDK


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
        "Getting Started" => "start.md",
        "Variables" => "variables.md",
        "Factors" => "factors.md",
        "Build a Graph" => "buildgraph.md",
        "Graph Solvers" => "solvers.md",
        "Index" => "summary.md",
    ],
)

deploydocs(;
    repo="github.com/NavAbility/NavAbilitySDK.jl",
    devbranch="main",
)
