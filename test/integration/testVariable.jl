module TestVariable

using Test

include("../../src/NavAbilitySDK.jl")
using .NavAbilitySDK

MAX_POLLING_TRIES = 150

function testAddVariable(apiUrl, userId, robotId, sessionId)
    client = NavAbilityHttpsClient(apiUrl)
    context = Client(userId,robotId,sessionId)
    testVariableLabels = ["x0", "x1"]
    testVariableTypes = ["RoME.Pose2","RoME.Pose2"]
    addVariable(client,context,Variable(testVariableLabels[1], testVariableTypes[1]))
    addVariable(client,context,Variable(testVariableLabels[2], testVariableTypes[2]))
    return true
end

function testLs(apiUrl, userId, robotId, sessionId)
    client = NavAbilityHttpsClient(apiUrl)
    context = Client(userId,robotId,sessionId)
    testVariableLabels = ["x0", "x1"]
    testVariableTypes = ["RoME.Pose2","RoME.Pose2"]
    addVariable(client,context,Variable(testVariableLabels[1], testVariableTypes[1]))
    addVariable(client,context,Variable(testVariableLabels[2], testVariableTypes[2]))
    for i in 1:MAX_POLLING_TRIES
        actualVariableLabels = ls(client,context)
        if setdiff(testVariableLabels,actualVariableLabels) == []
            return true
        end
        sleep(2)
        if i % 10 == 0
            @info "Polling for: $(setdiff(testVariableLabels,actualVariableLabels))"
        end
    end
    return false
end

function testGetVariable(apiUrl, userId, robotId, sessionId)
    client = NavAbilityHttpsClient(apiUrl)
    context = Client(userId,robotId,sessionId)
    testVariableLabels = ["x0", "x1"]
    testVariableTypes = ["RoME.Pose2","RoME.Pose2"]
    addVariable(client,context,Variable(testVariableLabels[1], testVariableTypes[1]))
    addVariable(client,context,Variable(testVariableLabels[2], testVariableTypes[2]))
    addSucceeded = false
    for i in 1:MAX_POLLING_TRIES
        actualVariableLabels = ls(client,context)
        if setdiff(testVariableLabels,actualVariableLabels) == []
            addSucceeded = true
            break
        end
        sleep(2)
        if i % 10 == 0
            @info "Polling for: $(setdiff(testVariableLabels,actualVariableLabels))"
        end
    end
    if !addSucceeded return false end
    for i in 1:size(testVariableLabels)[1]
        actualVariable = getVariable(client,context,testVariableLabels[i])
        if !(actualVariable["label"] == testVariableLabels[i])
            return false
        end
        if !(actualVariable["variableType"] == testVariableTypes[i])
            return false
        end
    end
    return true
end

function testGetVariables(apiUrl, userId, robotId, sessionId)
    client = NavAbilityHttpsClient(apiUrl)
    context = Client(userId,robotId,sessionId)
    testVariableLabels = ["x0", "x1"]
    testVariableTypes = ["RoME.Pose2","RoME.Pose2"]
    addVariable(client,context,Variable(testVariableLabels[1], testVariableTypes[1]))
    addVariable(client,context,Variable(testVariableLabels[2], testVariableTypes[2]))
    addSucceeded = false
    for i in 1:MAX_POLLING_TRIES
        actualVariableLabels = ls(client,context)
        if setdiff(testVariableLabels,actualVariableLabels) == []
            addSucceeded = true
            break
        end
        sleep(2)
        if i % 10 == 0
            @info "Polling for: $(setdiff(testVariableLabels,actualVariableLabels))"
        end
    end
    if !addSucceeded return false end
    variables = getVariables(client,context)
    for v in variables
        if !haskey(v,"label") || !haskey(v,"variableType")
            return false
        end
        if v["label"] == "x0" && !(v["variableType"] == "RoME.Pose2")
            return false
        end
        if v["label"] == "x1" && !(v["variableType"] == "RoME.Pose2")
            return false
        end
    end
    return true
end

function RunTests(apiUrl, userId, robotId, sessionId)
    @testset "variable-testset" begin
        @info "Running variable-testset"

        @test testAddVariable(apiUrl, userId, robotId, sessionId*"_testAddVariable")
        @test testLs(apiUrl, userId, robotId, sessionId*"_testLs")
        @test testGetVariable(apiUrl, userId, robotId, sessionId*"_testGetVariable")
        @test testGetVariables(apiUrl, userId, robotId, sessionId*"_testGetVariables")
    end
end

end