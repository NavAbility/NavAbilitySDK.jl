using Test
using Random

include("./fixtures.jl")
include("./testVariable.jl")
include("./testInitVariable.jl")
include("./testFactor.jl")
include("./testSolve.jl")
include("./testExportSession.jl")

apiUrl = get(ENV, "API_URL", "https://api.d1.navability.io")
userId = get(ENV, "USER_ID", "guest@navability.io")
robotId = get(ENV, "ROBOT_ID", "IntegrationRobot")
sessionId = get(ENV, "SESSION_ID", "TestSession" * randstring(7))
sessionId1d = get(ENV, "SESSION_ID", "TestSession1D" * randstring(7))
sessionId2d = get(ENV, "SESSION_ID", "TestSession2D" * randstring(7))
sessionId3d = get(ENV, "SESSION_ID", "TestSession3D" * randstring(7))

@testset "nva-sdk-integration-testset" begin
    # Creating one client and two contexts
    client, context1D = createClients(apiUrl, userId, robotId, sessionId1d)
    client, context2D = createClients(apiUrl, userId, robotId, sessionId2d)

    @info "Running nva-sdk-integration-testset..."

    # Note - Tests incrementally build on each other because this is an
    # integration test.
    runVariableTests(client, context2D)
    runFactorTests(client, context2D)
    runSolveTests(client, context2D)
    runExportTests(client, context2D)
    runInitVariableTests(; client)
    # test fixtures
    exampleGraph1D(client, context1D; doSolve = false)
end

@testset "testing Pose3" begin
    client, context3D = createClients(apiUrl, userId, robotId, sessionId3d)

    resultIds = Task[]
    append!(
        resultIds,
        [
            addVariable!(client, context3D, "x0", :Pose3),
            addVariable!(client, context3D, "x1", :Pose3),
        ],
    )

    NvaSDK.waitForCompletion(
        client,
        resultIds;
        maxSeconds = 180,
        expectedStatuses = ["Complete"],
    )

    resultIds = Task[]
    append!(
        resultIds,
        [
            addFactor(
                client,
                context3D,
                ["x0"],
                NvaSDK.PriorPose3(;
                    Z = NvaSDK.FullNormal(
                        [0.0, 1.0, 0, 0, 0, 0],
                        diagm([0.1, 0.1, 0.1, 0.01, 0.01, 0.01] .^ 2),
                    ),
                ),
            ),
            addFactor(
                client,
                context3D,
                [:x0, :x1],
                NvaSDK.Pose3Pose3Rotation(;
                    Z = NvaSDK.FullNormal([0.1, 0.0, 0], diagm([0.01, 0.01, 0.01] .^ 2)),
                ),
            ),
        ],
    )

    NvaSDK.waitForCompletion(
        client,
        resultIds;
        maxSeconds = 180,
        expectedStatuses = ["Complete"],
    )

    flabels = fetch(NvaSDK.listFactors(client, context3D))
    fac = fetch(NvaSDK.getFactor(client, context3D, "x0x1f_4e37"))

    # r = fetch(NvaSDK.solveSession(client, context3D))
    # s = fetch(NvaSDK.getStatusesLatest(client, [r]))
    # v = fetch(NvaSDK.getVariable(client, context3D, "x1"))

end
