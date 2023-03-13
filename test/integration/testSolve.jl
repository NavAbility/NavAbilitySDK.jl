
function checkForSolveKeys(client, context, key::String, variableLabelsToTest::Vector{String})
    for v in variableLabelsToTest
        variable = fetch( getVariable(client, context, v) )
        solveKeys = map(p -> p["solveKey"], variable["ppes"])
        @test key in solveKeys
    end
end

function testSolveSession(client, context, variableLabels; maxSeconds=180)
    # allVariableLabels = ls(client, context, variableLabels)
    
    # do the solve
    resultId = solveSession(client,context) |> fetch
    @info "solveSession" resultId
    GraphVizApp(context)
    # Wait for them to be done before proceeding.
    # NvaSDK.waitForCompletion2(client, resultId; maxSeconds)
    NvaSDK.waitForCompletion(client, [resultId;]; maxSeconds, expectedStatuses=["Complete"])

    # Get PPE's are there for the connected variables.
    # TODO - complete the factor graph.
    checkForSolveKeys(client, context, "default", variableLabels)
end

function testSolveSessionParametric(client, context, variableLabels; maxSeconds=240)
    # allVariableLabels = ls(client, context, variableLabels)
    
    # do the solve
    options = SolveOptions(key="parametric", useParametric=true)
    eventId = solveSession(client, context, options) |> fetch
    # Wait for them to be done before proceeding.
    @info "test solveParametric eventId" eventId
    waitForCompletion(client, [eventId;]; expectedStatuses=["Complete"], maxSeconds)

    # Get PPE's are there for the connected variables.
    # TODO - complete the factor graph.
    checkForSolveKeys(client, context, "parametric", variableLabels)
end


function testVizHelpersApp(context)
    @show GraphVizApp(context)
    @show MapVizApp(context)
    
    nothing
end

function runSolveTests(client, context)
    @testset "solve-testset" begin
        @info "Running solve-testset"

        # TODO: Test the rest of the variables.
        variableLabels = ["x0", "x1"]

        testSolveSession(client, context, variableLabels)
        testSolveSessionParametric(client, context, variableLabels)
    end
    
    @testset "appviz-testset" begin
        # generate viz help objects from current context
        testVizHelpersApp(context) 
    end
end
