
function testSolveSession(client, context, variableLabels; maxSeconds=180)
    # allVariableLabels = ls(client, context, variableLabels)

    resultId = solveSession(client,context)

    # Wait for them to be done before proceeding.
    waitForCompletion(client, Task[resultId;]; expectedStatuses=["Complete"], maxSeconds)

    # Get PPE's are there for the connected variables.
    # TODO - complete the factor graph.
    for v in variableLabels # getVariables(client, context, detail=SUMMARY)
        # First solve key (only) is the default result
        @test fetch( getVariable(client, context, v) )["ppes"][1]["solveKey"] == "default"
    end
end

function runSolveTests(client, context)
    @testset "solve-testset" begin
        @info "Running solve-testset"

        # TODO: Test the rest of the variables.
        variableLabels = ["x0", "x1"]

        testSolveSession(client, context, variableLabels)
    end
end
