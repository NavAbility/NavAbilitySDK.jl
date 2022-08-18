using NavAbilitySDK
NVA = NavAbilitySDK
using Test
using JSON
using LinearAlgebra
using Random

#include("./unit/runtests.jl")
include("./integration/runtests.jl")

#TODO I'm not familiar with the tests yet, so just dumping it here to get us started.
include("./integration/testStandardAPI.jl")