using NavAbilitySDK
using Test
using JSON3
using LinearAlgebra
using Random
using UUIDs

apiUrl = get(ENV, "API_URL", "https://api.d1.navability.io")
userLabel = get(ENV, "USER_ID", "guest@navability.io")
robotLabel = get(ENV, "ROBOT_ID", "TestRobot")
sessionLabel = get(ENV, "SESSION_ID", "TestSession_$(randstring)")

@testset "nva-sdk-standard-api-testset" begin
    client = NvaSDK.NavAbilityClient(apiUrl)
    fgclient = NvaSDK.DFGClient(
        client,
        userLabel,
        robotLabel,
        sessionLabel;
        addRobotIfNotExists = true,
        addSessionIfNotExists = true,
    )

    NvaSDK.addVariable!(fgclient, :x0, "Pose2")
    NvaSDK.addFactor!(
        fgclient,
        [:x0],
        NvaSDK.PriorPose2(; Z = NvaSDK.FullNormal([0.0, 1.0, 0], diagm([1.0, 1, 1]))),
    )

    NvaSDK.addVariable!(fgclient, :x1, :Pose2)
    NvaSDK.addFactor!(
        fgclient,
        [:x0, :x1],
        NvaSDK.Pose2Pose2(; Z = NvaSDK.FullNormal([1.0, 0.0, 0], diagm([1.0, 1, 1]))),
    )

    NvaSDK.addFactor!(
        fgclient,
        [:x1],
        NvaSDK.PriorPose2(; Z = NvaSDK.FullNormal([1.0, 0.0, 0], diagm([1.0, 1, 1])));
        nullhypo = 0.1,
    )

    NvaSDK.addFactor!(
        fgclient,
        ["x0"],
        NvaSDK.PriorPose2(; Z = NvaSDK.FullNormal([0.5, 0.5, 0], diagm([1.0, 1, 1]))),
    )

    NvaSDK.addVariable!(fgclient, :x2_a, :Pose2)
    NvaSDK.addVariable!(fgclient, :x2_b, :Pose2)
    NvaSDK.addFactor!(
        fgclient,
        ["x1", "x2_a", "x2_b"],
        NvaSDK.PriorPose2(; Z = NvaSDK.FullNormal([0.5, 0.5, 0], diagm([1.0, 1, 1])));
        multihypo = [1, 0.1, 0.9],
    )

    NvaSDK.addVariable!(fgclient, "y0", :Position1)
    NvaSDK.addFactor!(fgclient, ["y0"], NvaSDK.Prior(; Z = NvaSDK.Normal(0.0, 1.0)))

    NvaSDK.addVariable!(fgclient, "z0", :Point2)
    NvaSDK.addFactor!(
        fgclient,
        ["z0"],
        NvaSDK.PriorPoint2(; Z = NvaSDK.FullNormal([1.0, 0.0], diagm([1.0, 1]))),
    )

    NvaSDK.addVariable!(fgclient, "z1", :Point2)
    NvaSDK.addFactor!(
        fgclient,
        ["z0", "z1"],
        NvaSDK.Point2Point2(; Z = NvaSDK.FullNormal([1.0, 0.0], diagm([1.0, 1]))),
    )

    NvaSDK.addVariable!(fgclient, "p3_0", :Pose3)
    NvaSDK.addFactor!(
        fgclient,
        ["p3_0"],
        NvaSDK.PriorPose3(;
            Z = NvaSDK.FullNormal([0.0; 1.0; 0; zeros(3)], diagm([1.0; 1; 1; ones(3)])),
        ),
    )

    NvaSDK.addVariable!(fgclient, :p3_1, :Pose3)
    NvaSDK.addFactor!(
        fgclient,
        [:p3_0, :p3_1],
        NvaSDK.Pose3Pose3(;
            Z = NvaSDK.FullNormal([1.0; 0.0; 0; zeros(3)], diagm([1.0; 1; 1; ones(3)])),
        ),
    )

    @test length(listVariables(fgclient)) == 9
    @test length(listFactors(fgclient)) == 10

    #test adding variable that already exists
    @test_throws NvaSDK.GQL.GraphQLError NvaSDK.addVariable!(fgclient, :x0, :Pose2)
    

end



