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

    sessionKey = NVA.SessionKey(userId,robotId,sessionId)
    variableWhere = NVA.VariableWhere(sessionKey, "x0", NVA.POSE2)
    particleInput = Dict{String,Any}("points"=>points)
    distributionInput = Dict{String,Any}("particle"=>particleInput)
    initVarInp = NVA.InitVariableInput(variableWhere, distributionInput)

    eventId = NVA.initVariable(client, context, initVarInp) |> fetch
    @info "waitForCompletion on initVariable" eventId 
    NVA.waitForCompletion(client, [eventId], expectedStatuses=["Complete"], maxSeconds=180)

    res = NVA.getVariable(client, context, "x0")
    x0 = fetch(res)

    # FIXME cannot remember which way round the reshape should work
    x0_vv = reshape(x0["solverData"][1]["vecval"],3,:) 
    @cast refvv[i][d] := x0_vv[d,i]

    @test isapprox(pts, refvv; atol=1e-8)
  end
end

#