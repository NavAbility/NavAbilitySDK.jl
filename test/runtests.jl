using Aqua
using NavAbilitySDK
using Test

Aqua.test_all(
    NavAbilitySDK;
    piracies = (treat_as_own = [DFG.getId], )
)

if !haskey(ENV, "AUTH_TOKEN")
    @error "#FIXME Skipping tests because AUTH_TOKEN is not set"
else
include("./unit/runtests.jl")
@test_skip include("./integration/runtests.jl")

include("./integration/testStandardAPI.jl")
include("./integration/testBlobStore.jl")
include("./integration/InterfaceTests.jl")
end