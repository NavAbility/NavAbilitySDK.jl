# test initVariable




function runInitVariableTests()
  @testset "run initVariable tests" begin
    
    ##
    userId = "guest@navability.io"
    robotId = "TESTING"
    sessionId = "INIT_"*(string(NVA.uuid4())[1:4])
    # connections
    @show context = NVA.Client(userId,robotId,sessionId)
    client = NVA.NavAbilityHttpsClient(;authorize=false)
    resultId = NVA.addVariable(client, context, NVA.Variable("x0", :Pose2))
    # Wait for them to be done before proceeding.
    NVA.waitForCompletion(client, [resultId], expectedStatuses=["Complete"], maxSeconds=180)
    
    # init some value to variable x0
    points = [ NVA.CartesianPointInput(;x=-rand(),y=rand(),rotz=-0.1) for _ in 1:5 ]

    NVA.initVariableEvent(client, context, "x0", NVA.POSE2, points)
  end
end

#