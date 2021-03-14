# Highest level interface for just getting started. Only requires our SDK.
using NavAbilitySDK
using Test

# Do not include Compat libraries

# Setup environment
hostname = if haskey(ENV, "HOSTNAME") ENV["HOSTNAME"] else "localhost" end
token = if haskey(ENV, "TOKEN") ENV["TOKEN"] else "" end

# Connect to NavAbility
dfg = CloudDFG(host=hostname, token=token)
@info "Connection: $(cdfg)"
@test cdfg !== nothing

# Run operations against NavAbility
NavAbilitySDK.addVariable!(dfg, :x0, Pose2)
NavAbilitySDK.addFactor!(dfg, :x0, :x1, Pose2Pose2)
NavAbilitySDK.solve!(dfg)

# Assert success
@test true
