@testset "FactorData Tests" begin
  
  f = PriorPose2Data(Z = FullNormal([0.0, 0.0, 0.0], diagm([0.01, 0.01, 0.01])))
  @test JSON.json(f) == "{\"eliminated\":false,\"potentialused\":false,\"edgeIDs\":[],\"fnc\":{\"Z\":{\"mu\":[0.0,0.0,0.0],\"cov\":[0.01,0.0,0.0,0.0,0.01,0.0,0.0,0.0,0.01],\"_type\":\"IncrementalInference.PackedFullNormal\"}},\"multihypo\":[],\"certainhypo\":[1],\"nullhypo\":0.0,\"solveInProgress\":0,\"inflation\":3.0}"

  f = Pose2Pose2Data(Z = FullNormal([0.0, 0.0, 0.0], diagm([0.01, 0.01, 0.01])))
  @test JSON.json(f) == "{\"eliminated\":false,\"potentialused\":false,\"edgeIDs\":[],\"fnc\":{\"Z\":{\"mu\":[0.0,0.0,0.0],\"cov\":[0.01,0.0,0.0,0.0,0.01,0.0,0.0,0.0,0.01],\"_type\":\"IncrementalInference.PackedFullNormal\"}},\"multihypo\":[],\"certainhypo\":[1,2],\"nullhypo\":0.0,\"solveInProgress\":0,\"inflation\":3.0}"

  # Pose2AprilTag4CornersData
  f = Pose2AprilTag4CornersData(
    0,
    zeros(8),
    zeros(9),
    K=[300.0, 0.0, 0.0, 0.0, 300.0, 0.0, 180.0, 120.0, 1.0],
    taglength=0.25
  )
  @test JSON.json(f) == "{\"eliminated\":false,\"potentialused\":false,\"edgeIDs\":[],\"fnc\":{\"corners\":[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],\"homography\":[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],\"K\":[300.0,0.0,0.0,0.0,300.0,0.0,180.0,120.0,1.0],\"taglength\":0.25,\"id\":0,\"_type\":\"/application/JuliaLang/PackedPose2AprilTag4Corners\"},\"multihypo\":[],\"certainhypo\":[1,2],\"nullhypo\":0.0,\"solveInProgress\":0,\"inflation\":3.0}"


end