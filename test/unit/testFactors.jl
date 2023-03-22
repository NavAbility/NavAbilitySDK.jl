@testset "FactorData Tests" begin
    f = NvaSDK.Prior(; Z = NvaSDK.Normal(0.0, 10.0))
    @test JSON3.write(f) ==
          "{\"eliminated\":false,\"potentialused\":false,\"edgeIDs\":[],\"fnc\":{\"Z\":{\"mu\":0.0,\"sigma\":10.0,\"_type\":\"IncrementalInference.PackedNormal\"}},\"multihypo\":[],\"certainhypo\":[1],\"nullhypo\":0.0,\"solveInProgress\":0,\"inflation\":3.0}"

    f = NvaSDK.PriorPose2(;
        Z = NvaSDK.FullNormal([0.0, 0.0, 0.0], diagm([0.01, 0.01, 0.01])),
    )
    @test JSON3.write(f) ==
          "{\"eliminated\":false,\"potentialused\":false,\"edgeIDs\":[],\"fnc\":{\"Z\":{\"mu\":[0.0,0.0,0.0],\"cov\":[0.01,0.0,0.0,0.0,0.01,0.0,0.0,0.0,0.01],\"_type\":\"IncrementalInference.PackedFullNormal\"}},\"multihypo\":[],\"certainhypo\":[1],\"nullhypo\":0.0,\"solveInProgress\":0,\"inflation\":3.0}"

    f = NvaSDK.PriorPoint2(; Z = NvaSDK.FullNormal([0.0, 0.0], diagm([0.01, 0.01])))
    @test JSON3.write(f) ==
          "{\"eliminated\":false,\"potentialused\":false,\"edgeIDs\":[],\"fnc\":{\"Z\":{\"mu\":[0.0,0.0],\"cov\":[0.01,0.0,0.0,0.01],\"_type\":\"IncrementalInference.PackedFullNormal\"}},\"multihypo\":[],\"certainhypo\":[1],\"nullhypo\":0.0,\"solveInProgress\":0,\"inflation\":3.0}"

    f = NvaSDK.LinearRelative(; Z = NvaSDK.Normal(5.0, 10.0))
    @test JSON3.write(f) ==
          "{\"eliminated\":false,\"potentialused\":false,\"edgeIDs\":[],\"fnc\":{\"Z\":{\"mu\":5.0,\"sigma\":10.0,\"_type\":\"IncrementalInference.PackedNormal\"}},\"multihypo\":[],\"certainhypo\":[1,2],\"nullhypo\":0.0,\"solveInProgress\":0,\"inflation\":3.0}"

    f = NvaSDK.Pose2Pose2(;
        Z = NvaSDK.FullNormal([0.0, 0.0, 0.0], diagm([0.01, 0.01, 0.01])),
    )
    @test JSON3.write(f) ==
          "{\"eliminated\":false,\"potentialused\":false,\"edgeIDs\":[],\"fnc\":{\"Z\":{\"mu\":[0.0,0.0,0.0],\"cov\":[0.01,0.0,0.0,0.0,0.01,0.0,0.0,0.0,0.01],\"_type\":\"IncrementalInference.PackedFullNormal\"}},\"multihypo\":[],\"certainhypo\":[1,2],\"nullhypo\":0.0,\"solveInProgress\":0,\"inflation\":3.0}"

    # Pose2AprilTag4CornersData
    f = NvaSDK.Pose2AprilTag4Corners(;
        id = 0,
        corners= zeros(8),
        homography = zeros(9),
        K = [300.0, 0.0, 0.0, 0.0, 300.0, 0.0, 180.0, 120.0, 1.0],
        taglength = 0.25,
    )
    @test JSON3.write(f) ==
          "{\"eliminated\":false,\"potentialused\":false,\"edgeIDs\":[],\"fnc\":{\"corners\":[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],\"homography\":[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],\"K\":[300.0,0.0,0.0,0.0,300.0,0.0,180.0,120.0,1.0],\"taglength\":0.25,\"id\":0,\"_type\":\"/application/JuliaLang/PackedPose2AprilTag4Corners\"},\"multihypo\":[],\"certainhypo\":[1,2],\"nullhypo\":0.0,\"solveInProgress\":0,\"inflation\":3.0}"

    # Pose2Point2BearingRangeData
    f = NvaSDK.Pose2Point2BearingRange(; bearing = NvaSDK.Normal(0, 5), range = NvaSDK.Normal(20, 1))
    @test JSON3.write(f) ==
          "{\"eliminated\":false,\"potentialused\":false,\"edgeIDs\":[],\"fnc\":{\"bearstr\":{\"mu\":0.0,\"sigma\":5.0,\"_type\":\"IncrementalInference.PackedNormal\"},\"rangstr\":{\"mu\":20.0,\"sigma\":1.0,\"_type\":\"IncrementalInference.PackedNormal\"}},\"multihypo\":[],\"certainhypo\":[1,2],\"nullhypo\":0.0,\"solveInProgress\":0,\"inflation\":3.0}"

    # Point2Point2RangeData
    f = NvaSDK.Point2Point2Range(; Z = NvaSDK.Normal(20, 1))
    @test JSON3.write(f) ==
          "{\"eliminated\":false,\"potentialused\":false,\"edgeIDs\":[],\"fnc\":{\"Z\":{\"mu\":20.0,\"sigma\":1.0,\"_type\":\"IncrementalInference.PackedNormal\"}},\"multihypo\":[],\"certainhypo\":[1,2],\"nullhypo\":0.0,\"solveInProgress\":0,\"inflation\":3.0}"

    # MixtureData
    @test_broken f = NvaSDK.Mixture(
        LinearRelativeData,
        (hypo1 = NvaSDK.Normal(0, 2), hypo2 = Uniform(30, 55)),
        [0.4, 0.6],
        2,
    )
    @test JSON3.write(f) ==
          "{\"eliminated\":false,\"potentialused\":false,\"edgeIDs\":[],\"fnc\":{\"N\":2,\"F_\":\"PackedLinearRelative\",\"S\":[\"hypo1\",\"hypo2\"],\"components\":[{\"mu\":0.0,\"sigma\":2.0,\"_type\":\"IncrementalInference.PackedNormal\"},{\"a\":30.0,\"b\":55.0,\"_type\":\"IncrementalInference.PackedUniform\"}],\"diversity\":{\"p\":[0.4,0.6],\"_type\":\"IncrementalInference.PackedCategorical\"}},\"multihypo\":[],\"certainhypo\":[],\"nullhypo\":0.0,\"solveInProgress\":0,\"inflation\":3.0}"

    # ScatterAlignPose2 and implicityly ManifoldKernelDensity
    Random.seed!(42)
    pts1 = [randn(2) for i = 1:50]
    pts2 = [randn(2) for i = 1:50]
    @test_broken begin 
        sap = NvaSDK.ScatterAlignPose2("Point2", pts1, pts2)
        fid = open(joinpath(@__DIR__, "testdata", "sap_test.json"))
        ref = readline(fid)
        close(fid)
        str = JSON3.write(sap)
        @warn "Suppress test, Random.seed! or reference string not working the same as local tests which passed."
    end
    # @test ref == str

end
