# test initVariable

using TensorCast


function runInitVariableTests(;client = NVA.NavAbilityHttpsClient(;authorize=false))
  @testset "run initVariable tests" begin
    
    ##
    userId = "guest@navability.io"
    robotId = "TESTING"
    sessionId = "INITVARIABLE_"*(string(NVA.uuid4())[1:4])
    # connections
    @show context = NVA.Client(userId,robotId,sessionId)
    
    resultId = NVA.addVariable(client, context, NVA.Variable("x0", :Pose2))
    # Wait for them to be done before proceeding.
    NVA.waitForCompletion(client, [resultId], expectedStatuses=["Complete"], maxSeconds=180)
    
    # init some value to variable x0
    pts = [[-rand();rand();-0.1] for _ in 1:5]
    points = Dict{String,Float64}[ NVA.CartesianPointInput(;x=pt[1],y=pt[2],rotz=pt[3]) for pt in pts ]

    sessionKey = NVA.SessionKey(userId,robotId,sessionId)
    variableWhere = NVA.VariableWhere(sessionKey, "x0", NVA.POSE2)
    particleInput = Dict{String,Any}("points"=>points)
    distributionInput = Dict{String,Any}("particle"=>particleInput)
    # distr = Dict{String,Any}("distribution"=>distributionInput)
    initVarInp = NVA.InitVariableInput(variableWhere, distributionInput)

    NVA.initVariableEvent(client, context, initVarInp)

    @warn "TODO, get values back from API to make sure numerics were properly set."
    res = NVA.getVariable(client, context, "x0")
    x0 = fetch(res)

    # FIXME cannot remember which way round the reshape should work
    x0_vv = reshape(x0["solverData"][1]["vecval"],3,:) 
    @cast refvv[i][d] := x0_vv[d,i]

    @test isapprox(pts, refvv; atol=1e-8)
  end
end

#