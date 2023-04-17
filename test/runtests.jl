include("./unit/runtests.jl")
@test_skip include("./integration/runtests.jl")

include("./integration/testStandardAPI.jl")
include("./integration/testBlobStore.jl")
include("./integration/InterfaceTests.jl")
