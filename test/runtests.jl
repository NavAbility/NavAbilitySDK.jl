using Aqua
using NavAbilitySDK
using Test

Aqua.test_all(
    NavAbilitySDK;
    piracies = (treat_as_own = [DFG.getId],),
)

if !haskey(ENV, "AUTH_TOKEN") || isempty(ENV["AUTH_TOKEN"])
    @error "Skipping integration tests because AUTH_TOKEN is not set"
else
    include("integration/runtests.jl")
end
