# test initVariable

using TensorCast

function runInitVariableTests(;
    client = NvaSDK.NavAbilityHttpsClient(; authorize = false),
    userId = "guest@navability.io",
    robotId = "TESTING",
    sessionId = "INITVARIABLE_" * (string(NvaSDK.uuid4())[1:4]),
)
    #
    @testset "run initVariable tests" begin

        ##
        # connections
        @show context = NvaSDK.Client(userId, robotId, sessionId)

        resultId =
            NvaSDK.addVariable!(client, context, NvaSDK.Variable("x0", :Pose2)) |> fetch
        # Wait for them to be done before proceeding.
        @info "Wait on addVariable eventId" resultId
        NvaSDK.waitForCompletion(
            client,
            [resultId];
            expectedStatuses = ["Complete"],
            maxSeconds = 180,
        )

        # init some value to variable x0
        pts = [[-rand(); rand(); -0.1] for _ = 1:5]
        points = Dict{String, Float64}[
            NvaSDK.CartesianPointInput(; x = pt[1], y = pt[2], rotz = pt[3]) for pt in pts
        ]

        variableKey = NvaSDK.VariableKey(userId, robotId, sessionId, "x0")
        variableId = NvaSDK.VariableId(variableKey)
        particleInput = Dict{String, Any}("points" => points)
        distributionInput = Dict{String, Any}("particle" => particleInput)
        initVarInp = NvaSDK.InitVariableInput(variableId, NvaSDK.POSE2, distributionInput)

        eventId = NvaSDK.initVariable(client, context, initVarInp) |> fetch
        @info "waitForCompletion on initVariable" eventId
        completedSuccessfully = NvaSDK.waitForCompletion2(client, eventId) #, expectedStatuses=["Complete"], maxSeconds=180)
        @test completedSuccessfully
        if completedSuccessfully
            res = NvaSDK.getVariable(client, context, "x0")
            x0 = fetch(res)
            x0_vv = reshape(x0["solverData"][1]["vecval"], 3, :)
            @cast refvv[i][d] := x0_vv[d, i]
            @show pts, refvv
            @test isapprox(pts, refvv; atol = 1e-12)
        end
    end
end

#
