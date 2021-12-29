include("./testVariable.jl")

using Test
using Random
using .TestVariable

apiUrl = get(ENV,"API_URL","http://localhost:4343")
userId = get(ENV,"USER_ID","Guest")
robotId = get(ENV,"ROBOT_ID","IntegrationRobot")
sessionId = get(ENV,"SESSION_ID",randstring(7))

@testset "nva-sdk-integration-testset" begin
    @info "Running nva-sdk-integration-testset..."
    TestVariable.RunTests(apiUrl, userId, robotId, sessionId)
end
