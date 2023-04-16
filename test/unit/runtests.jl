using NavAbilitySDK
using Test
using JSON3
using LinearAlgebra
using Random
using DistributedFactorGraphs

include("./testDistributions.jl")
include("./testFactors.jl") 
@test_skip include("./testVariables.jl") #TODO update or rewrite, these are hard to maintain on changes.

