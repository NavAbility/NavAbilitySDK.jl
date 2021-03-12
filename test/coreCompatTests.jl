# Ensure NavAbility SDK components work within core ecosystem
using NavAbilitySDK
using Test
using JSON

# Compat Libraries
using DistributedFactorGraphs
using IncrementalInference
using RoME

# Setup environment
hostname = if haskey(ENV, "HOSTNAME") ENV["HOSTNAME"] else "localhost" end
token = if haskey(ENV, "TOKEN") ENV["TOKEN"] else "" end

# Connect to NavAbility
dfg = NVADFG(host=hostname, token=token)
@info "Connection: $(dfg)"
@test dfg !== nothing

# Run operations against NavAbility
DistributedFactorGraphs.addVariable!(dfg, :x0, Pose2)
DistributedFactorGraphs.addFactor!(dfg, :x0, :x1, Pose2Pose2)
IncrementalInference.solveTree!(dfg)

# Assert success
@test true
