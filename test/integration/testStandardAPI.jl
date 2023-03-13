apiUrl = get(ENV,"API_URL","https://api.navability.io")
userId = get(ENV,"USER_ID","guest@navability.io")
robotId = get(ENV,"ROBOT_ID","IntegrationRobot")
sessionId = get(ENV,"SESSION_ID","TestSession_"*string(uuid4())[1:8])

@testset "nva-sdk-standard-api-testset" begin
    
    client = NavAbilityHttpsClient(apiUrl)
    context = Client(userId,robotId,sessionId)

    addVariable(client, context,  "x0", :Pose2)
    addFactor(client, context, ["x0"], NvaSDK.PriorPose2(Z=FullNormal([0.,1.,0], diagm([1.,1,1]))))
    
    addVariable(client, context,  :x1, :Pose2)
    addFactor(client, context, [:x0,:x1], NvaSDK.Pose2Pose2(Z=FullNormal([1.,0.,0], diagm([1.,1,1]))))

    addFactor(client, context, [:x1], NvaSDK.PriorPose2(Z=FullNormal([1.,0.,0], diagm([1.,1,1]))); nullhypo=0.1)
    
    addFactor(client, context, ["x0"], NvaSDK.PriorPose2(Z=FullNormal([0.5,0.5,0], diagm([1.,1,1]))))
    
    addVariable(client, context,  :x2_a, :Pose2)
    addVariable(client, context,  :x2_b, :Pose2)
    addFactor(client, context, ["x1", "x2_a", "x2_b"], NvaSDK.PriorPose2(Z=FullNormal([0.5,0.5,0], diagm([1.,1,1]))); multihypo=[1,0.1,0.9])

    addVariable(client, context,  "y0", :Position1)
    addFactor(client, context, ["y0"], NvaSDK.Prior(Z=Normal(0.0, 1.0)))  


    addVariable(client, context,  "z0", :Point2)
    addFactor(client, context, ["z0"], NvaSDK.PriorPoint2(Z=FullNormal([1.,0.], diagm([1.,1]))))
    
    addVariable(client, context,  "z1", :Point2)
    addFactor(client, context, ["z0", "z1"], NvaSDK.Point2Point2(Z=FullNormal([1.,0.], diagm([1.,1]))))  

    addVariable(client, context,  "p3_0", :Pose3)
    addFactor(client, context, ["p3_0"], NvaSDK.PriorPose3(Z=FullNormal([0.;1.;0;zeros(3)], diagm([1.;1;1;ones(3)]))))
    
    addVariable(client, context,  :p3_1, :Pose3)
    addFactor(client, context, [:p3_0,:p3_1], NvaSDK.Pose3Pose3(Z=FullNormal([1.;0.;0;zeros(3)], diagm([1.;1;1;ones(3)]))))

end