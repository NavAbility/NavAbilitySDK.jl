include("./testVariable.jl")
include("./testFactor.jl")

using Test
using Random
using .TestVariable
using .TestFactor

apiUrl = get(ENV,"API_URL","https://api.d1.navability.io")
userId = get(ENV,"USER_ID","Guest")
robotId = get(ENV,"ROBOT_ID","IntegrationRobot")
sessionId = get(ENV,"SESSION_ID",randstring(7))

@testset "nva-sdk-integration-testset" begin
    @info "Running nva-sdk-integration-testset..."
    TestVariable.RunTests(apiUrl, userId, robotId, sessionId)
    TestFactor.RunTests(apiUrl, userId, robotId, sessionId)
end
