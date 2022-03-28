using Test
using Random

include("./fixtures.jl")
include("./testVariable.jl")
include("./testFactor.jl")
include("./testSolve.jl")

apiUrl = get(ENV,"API_URL","https://api.d1.navability.io")
userId = get(ENV,"USER_ID","Guest")
robotId = get(ENV,"ROBOT_ID","IntegrationRobot")
sessionId = get(ENV,"SESSION_ID","TestSession"*randstring(7))
# sessionId1d = get(ENV,"SESSION_ID","TestSession1D"*randstring(7))
sessionId2d = get(ENV,"SESSION_ID","TestSession2D"*randstring(7))

@testset "nva-sdk-integration-testset" begin
    # Creating one client and two contexts
    # client, navabilityClient1D = createClients(apiUrl, userId, robotId, sessionId1d)
    client, navabilityClient2D = createClients(apiUrl, userId, robotId, sessionId2d)

    @info "Running nva-sdk-integration-testset..."

    # Note - Tests incrementally build on each other because this is an
    # integration test.
    runVariableTests(client, navabilityClient2D)
    runFactorTests(client, navabilityClient2D)
    runSolveTests(client, navabilityClient2D)
end
