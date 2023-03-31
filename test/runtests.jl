include("./unit/runtests.jl")
@test_skip include("./integration/runtests.jl")

#TODO I'm not familiar with the tests yet, so just dumping it here to get us started.
include("./integration/testStandardAPI.jl")
