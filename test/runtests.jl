## This file should let you test the SDK independently
# You can also run it with ], then `test NavAbilitySDK`

using DistributedFactorGraphs
using NavAbilitySDK
using Test

# For testing, we need representative variables and factors from RoME
#using IncrementalInference
#using RoME

nvaSDK = NVADFG("$(@__DIR__)/configDevNavAbilty.json")
@info "Connection: $(nvaSDK)"
@test nvaSDK !== nothing

# TODO: As they say in the dating world, now make a connection

# TODO: Do an ls, or addVariable now... 
