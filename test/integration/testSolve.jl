MAX_POLLING_TRIES = 150

function testSolveSession(client, context)
    testVariableLabels = ls(client, context)

    resultId = solveSession(client,context)

    # Wait for them to be done before proceeding.
    waitForCompletion(client, [resultId], expectedStatuses=["Complete"])

    # Get PPE's to confirm all is there.
    # This'll blow up if not.
    Dict((vId=>getVariable(client, context, vId; detail=SUMMARY)["ppes"]["default"]) for vId in testVariableLabels)
end

function runSolveTests(client, context)
    @testset "solve-testset" begin
        @info "Running solve-testset"

        @test testSolveSession(client, context)
    end
end
