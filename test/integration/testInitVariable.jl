# test initVariable

using TensorCast


function runInitVariableTests(;
    client = NVA.NavAbilityHttpsClient(;authorize=false),
    userId = "guest@navability.io",
    robotId = "TESTING",
    sessionId = "INITVARIABLE_"*(string(NVA.uuid4())[1:4])
  )
  #
  @testset "run initVariable tests" begin
    
    ##
    # connections
    @show context = NVA.Client(userId,robotId,sessionId)
    
    resultId = NVA.addVariable(client, context, NVA.Variable("x0", :Pose2)) |> fetch
    # Wait for them to be done before proceeding.
    @info "Wait on addVariable eventId" resultId
    NVA.waitForCompletion(client, [resultId], expectedStatuses=["Complete"], maxSeconds=180)
    
    # init some value to variable x0
    pts = [[-rand();rand();-0.1] for _ in 1:5]
    points = Dict{String,Float64}[ NVA.CartesianPointInput(;x=pt[1],y=pt[2],rotz=pt[3]) for pt in pts ]

    variableKey = NVA.VariableKey(userId,robotId,sessionId,"x0")
    variableId = NVA.VariableId(variableKey)
    particleInput = Dict{String,Any}("points"=>points)
    distributionInput = Dict{String,Any}("particle"=>particleInput)
    initVarInp = NVA.InitVariableInput(variableId, NVA.POSE2, distributionInput)

    eventId = NVA.initVariable(client, context, initVarInp) |> fetch
    @info "waitForCompletion on initVariable" eventId 
    completedSuccessfully = NVA.waitForCompletion2(client, eventId) #, expectedStatuses=["Complete"], maxSeconds=180)
    @test completedSuccessfully
    if completedSuccessfully
      res = NVA.getVariable(client, context, "x0")
      x0 = fetch(res)
      x0_vv = reshape(x0["solverData"][1]["vecval"],3,:) 
      @cast refvv[i][d] := x0_vv[d,i]
      @show pts, refvv
      @test isapprox(pts, refvv; atol=1e-12)
    end
  end
end

#