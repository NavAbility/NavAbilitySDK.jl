using NavAbilitySDK
using Test
using JSON3
using LinearAlgebra
using Random

include("./testDistributions.jl")
include("./testFactors.jl") 
@test_broken include("./testVariables.jl") #TODO update or rewrite, these are hard to maintain on changes.

