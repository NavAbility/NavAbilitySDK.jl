# test initVariable




function runInitVariableTests()
  @testset "run initVariable tests" begin
    
    ##
    userId = "guest@navability.io"
    robotId = "TESTING"
    sessionId = "INITVARIABLE_"*(string(NVA.uuid4())[1:4])
    # connections
    @show context = NVA.Client(userId,robotId,sessionId)
    client = NVA.NavAbilityHttpsClient(;authorize=false)
    resultId = NVA.addVariable(client, context, NVA.Variable("x0", :Pose2))
    # Wait for them to be done before proceeding.
    NVA.waitForCompletion(client, [resultId], expectedStatuses=["Complete"], maxSeconds=180)
    
    # init some value to variable x0
    points = Dict{String,Float64}[ NVA.CartesianPointInput(;x=-rand(),y=rand(),rotz=-0.1) for _ in 1:5 ]

    sessionKey = NVA.SessionKey(userId,robotId,sessionId)
    variableWhere = NVA.VariableWhere(sessionKey, "x0", NVA.POSE2)
    particleInput = Dict{String,Any}("points"=>points)
    distributionInput = Dict{String,Any}("particle"=>particleInput)
    # distr = Dict{String,Any}("distribution"=>distributionInput)
    initVarInp = NVA.InitVariableInput(variableWhere, distributionInput)

    NVA.initVariableEvent(client, context, initVarInp)

    @warn "TODO, get values back from API to make sure numerics were properly set."
  end
end

#