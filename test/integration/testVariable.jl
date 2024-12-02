
function testAddVariable(
    client,
    context,
    variableLabels,
    variableTypes,
    variableTypeStrings,
)
    resultIds = Task[]
    for (index, label) in enumerate(variableLabels)
        resultId = addVariable!(client, context, VariableDFG(label, variableTypes[index]))
        @test resultId != "Error"
        push!(resultIds, resultId)
    end

    # Wait for them to be done before proceeding.
    # NvaSDK.waitForCompletion2(client, resultIds; maxSeconds=180) # expectedStatuses=["Complete"]
    NvaSDK.waitForCompletion(
        client,
        resultIds;
        maxSeconds = 180,
        expectedStatuses = ["Complete"],
    )

    return resultIds
end

function testUpdateVariable(
    client,
    context,
    variableLabels,
    variableTypes,
    variableTypeStrings,
)
    for i = 1:length(variableLabels)
        actualVariable = getVariable(client, context, variableLabels[i]) |> fetch
        push!(actualVariable["tags"], "TEST")
        eventId = updateVariablePacked(client, context, actualVariable) |> fetch
        NvaSDK.waitForCompletion(
            client,
            [eventId];
            maxSeconds = 180,
            expectedStatuses = ["Complete"],
        )

        actualVariable = getVariable(client, context, variableLabels[i]) |> fetch
        @test "TEST" in actualVariable["tags"]
    end
end

function testLs(client, context, variableLabels, variableTypes, variableTypeStrings)
    @test length(setdiff(variableLabels, fetch(ls(client, context)))) == 0
end

function testGetVariable(
    client,
    context,
    variableLabels,
    variableTypes,
    variableTypeStrings,
)
    for i = 1:length(variableLabels)
        actualVariable = getVariable(client, context, variableLabels[i]) |> fetch
        @test actualVariable["label"] == variableLabels[i]
        @test actualVariable["variableType"] == variableTypeStrings[i]
    end
end

function testGetVariables(
    client,
    context,
    variableLabels,
    variableTypes,
    variableTypeStrings,
)
    # Make a quick dictionary of the expected variable Types
    varIdType = Dict(variableLabels .=> variableTypeStrings)

    variables = getVariables(client, context; detail = SUMMARY) |> fetch
    for v in variables
        @test v["variableType"] == varIdType[v["label"]]
    end
end

function runVariableTests(client, context)
    @testset "Testing Variables" begin
        @info "Running variable-testset"

        variableLabels = ["x0", "x1", "l1", "x3"]
        variableTypes = [:Pose2, "RoME.Pose2", :Point2, :ContinuousScalar]
        variableTypeStrings =
            ["RoME.Pose2", "RoME.Pose2", "RoME.Point2", "IncrementalInference.Position{1}"]

        @testset "Adding" begin
            testAddVariable(
                client,
                context,
                variableLabels,
                variableTypes,
                variableTypeStrings,
            )
        end
        @testset "Updating" begin
            testUpdateVariable(
                client,
                context,
                variableLabels,
                variableTypes,
                variableTypeStrings,
            )
        end

        @testset "Listing" begin
            testLs(client, context, variableLabels, variableTypes, variableTypeStrings)
        end
        @testset "Getting" begin
            testGetVariable(
                client,
                context,
                variableLabels,
                variableTypes,
                variableTypeStrings,
            )
        end
        @testset "Getting Lists" begin
            testGetVariables(
                client,
                context,
                variableLabels,
                variableTypes,
                variableTypeStrings,
            )
        end
    end
end
