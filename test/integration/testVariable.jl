module TestVariable

using Test

include("../../src/NavAbilitySDK.jl")
using .NavAbilitySDK

MAX_POLLING_TRIES = 150

function testAddVariable(apiUrl, userId, robotId, sessionId, variableLabels, variableTypes, variableTypeStrings)
    client = NavAbilityHttpsClient(apiUrl)
    context = Client(userId,robotId,sessionId)

    for (index, label) in enumerate(variableLabels)
        @test addVariable(client,context,Variable(label, variableTypes[index])) != "Error"
    end
end

function testLs(apiUrl, userId, robotId, sessionId, variableLabels, variableTypes, variableTypeStrings)
    client = NavAbilityHttpsClient(apiUrl)
    context = Client(userId,robotId,sessionId)

    for (index, label) in enumerate(variableLabels)
        @test addVariable(client,context,Variable(label, variableTypes[index])) != "Error"
    end

    for i in 1:MAX_POLLING_TRIES
        actualVariableLabels = ls(client,context)
        if setdiff(variableLabels,actualVariableLabels) == []
            return
        end
        sleep(2)
        if i % 10 == 0
            @info "Polling for: $(setdiff(variableLabels,actualVariableLabels))"
        end
    end
    error("Exceeded polling time")
end

function testGetVariable(apiUrl, userId, robotId, sessionId, variableLabels, variableTypes, variableTypeStrings)
    client = NavAbilityHttpsClient(apiUrl)
    context = Client(userId,robotId,sessionId)

    for (index, label) in enumerate(variableLabels)
        addVariable(client,context,Variable(label, variableTypes[index]))
    end

    addSucceeded = false
    for i in 1:MAX_POLLING_TRIES
        actualVariableLabels = ls(client,context)
        if setdiff(variableLabels,actualVariableLabels) == []
            addSucceeded = true
            break
        end
        sleep(2)
        if i % 10 == 0
            @info "Polling for: $(setdiff(variableLabels,actualVariableLabels))"
        end
    end
    !addSucceeded && error("Exceeded polling time")

    for i in 1:size(variableLabels)[1]
        actualVariable = getVariable(client,context,variableLabels[i])
        @test actualVariable["label"] == variableLabels[i]
        @test actualVariable["variableType"] == variableTypeStrings[i]
    end
end

function testGetVariables(apiUrl, userId, robotId, sessionId, variableLabels, variableTypes, variableTypeStrings)
    client = NavAbilityHttpsClient(apiUrl)
    context = Client(userId,robotId,sessionId)

    for (index, label) in enumerate(variableLabels)
        addVariable(client,context,Variable(label, variableTypes[index]))
    end

    addSucceeded = false
    for i in 1:MAX_POLLING_TRIES
        actualVariableLabels = ls(client,context)
        if setdiff(variableLabels,actualVariableLabels) == []
            addSucceeded = true
            break
        end
        sleep(2)
        if i % 10 == 0
            @info "Polling for: $(setdiff(variableLabels,actualVariableLabels))"
        end
    end
    !addSucceeded && error("Exceeded polling time")
    # Make a quick dictionary of the expected variable Types
    varIdType = Dict(variableLabels .=> variableTypeStrings)

    variables = getVariables(client, context; detail=SUMMARY)
    for v in variables
        @test v["variableType"] == varIdType[v["label"]]
    end
end

function RunTests(apiUrl, userId, robotId, sessionId)
    @testset "Testing Variables" begin
        @info "Running variable-testset"

        variableLabels = ["x0", "x1", "l1", "x3"]
        variableTypes = [:Pose2,"RoME.Pose2", :Point2, :ContinuousScalar]
        variableTypeStrings = ["RoME.Pose2","RoME.Pose2", "RoME.Point2", "IncrementalInference.Position{1}"]
    
        @testset "Adding" begin testAddVariable(apiUrl, userId, robotId, sessionId*"_testAddVariable", variableLabels, variableTypes, variableTypeStrings); end
        @testset "Listing" begin testLs(apiUrl, userId, robotId, sessionId*"_testLs", variableLabels, variableTypes, variableTypeStrings); end
        @testset "Getting" begin testGetVariable(apiUrl, userId, robotId, sessionId*"_testGetVariable", variableLabels, variableTypes, variableTypeStrings); end
        @testset "Getting Lists" begin testGetVariables(apiUrl, userId, robotId, sessionId*"_testGetVariables", variableLabels, variableTypes, variableTypeStrings); end 
    end
end

end