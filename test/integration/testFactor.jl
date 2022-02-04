module TestFactor

using Test

include("../../src/NavAbilitySDK.jl")
using .NavAbilitySDK

MAX_POLLING_TRIES = 150


function testAddFactor(apiUrl, userId, robotId, sessionId)
    client = NavAbilityHttpsClient(apiUrl)
    context = Client(userId,robotId,sessionId)
    testVariableLabels = ["x0", "x1"]
    testVariableTypes = ["RoME.Pose2","RoME.Pose2"]
    addVariable(client,context,Variable(testVariableLabels[1], testVariableTypes[1]))
    addVariable(client,context,Variable(testVariableLabels[2], testVariableTypes[2]))
    testFactorLabels = ["x0x1f1","x0f1"]
    testFactorTypes = ["Pose2Pose2","PriorPose2"]
    addFactor(client,context,Factor(testFactorLabels[1], testFactorTypes[1], testVariableLabels, Pose2Pose2Data()))
    addFactor(client,context,Factor(testFactorLabels[2], testFactorTypes[2], [testVariableLabels[1]], PriorPose2Data()))
    return true
end

function testLsf(apiUrl, userId, robotId, sessionId)
    client = NavAbilityHttpsClient(apiUrl)
    context = Client(userId,robotId,sessionId)
    testVariableLabels = ["x0", "x1"]
    testVariableTypes = ["RoME.Pose2","RoME.Pose2"]
    addVariable(client,context,Variable(testVariableLabels[1], testVariableTypes[1]))
    addVariable(client,context,Variable(testVariableLabels[2], testVariableTypes[2]))
    variableAddSucceeded = false
    for i in 1:MAX_POLLING_TRIES
        actualVariableLabels = ls(client,context)
        if setdiff(testVariableLabels,actualVariableLabels) == []
            variableAddSucceeded = true
            break
        end
        sleep(2)
        if i % 10 == 0
            @info "Polling for: $(setdiff(testVariableLabels,actualVariableLabels))"
        end
    end
    if !variableAddSucceeded return false end
    testFactorLabels = ["x0x1f1","x0f1"]
    testFactorTypes = ["Pose2Pose2","PriorPose2"]
    addFactor(client,context,Factor(testFactorLabels[1], testFactorTypes[1], testVariableLabels, Pose2Pose2Data()))
    addFactor(client,context,Factor(testFactorLabels[2], testFactorTypes[2], [testVariableLabels[1]], PriorPose2Data()))
    factorAddSucceeded = false
    for i in 1:MAX_POLLING_TRIES
        actualFactorLabels = lsf(client,context)
        if setdiff(testFactorLabels,actualFactorLabels) == []
            factorAddSucceeded = true
            break
        end
        sleep(2)
        if i % 10 == 0
            @info "Polling for: $(setdiff(testFactorLabels,actualFactorLabels))"
        end
    end
    if !factorAddSucceeded return false end

    return true
end

function testGetFactor(apiUrl, userId, robotId, sessionId)
    client = NavAbilityHttpsClient(apiUrl)
    context = Client(userId,robotId,sessionId)
    testVariableLabels = ["x0", "x1"]
    testVariableTypes = ["RoME.Pose2","RoME.Pose2"]
    addVariable(client,context,Variable(testVariableLabels[1], testVariableTypes[1]))
    addVariable(client,context,Variable(testVariableLabels[2], testVariableTypes[2]))
    variableAddSucceeded = false
    for i in 1:MAX_POLLING_TRIES
        actualVariableLabels = ls(client,context)
        if setdiff(testVariableLabels,actualVariableLabels) == []
            variableAddSucceeded = true
            break
        end
        sleep(2)
        if i % 10 == 0
            @info "Polling for: $(setdiff(testVariableLabels,actualVariableLabels))"
        end
    end
    if !variableAddSucceeded return false end
    testFactorLabels = ["x0x1f1","x0f1"]
    testFactorTypes = ["Pose2Pose2","PriorPose2"]
    addFactor(client,context,Factor(testFactorLabels[1], testFactorTypes[1], testVariableLabels, Pose2Pose2Data()))
    addFactor(client,context,Factor(testFactorLabels[2], testFactorTypes[2], [testVariableLabels[1]], PriorPose2Data()))
    factorAddSucceeded = false
    for i in 1:MAX_POLLING_TRIES
        actualFactorLabels = lsf(client,context)
        if setdiff(testFactorLabels,actualFactorLabels) == []
            factorAddSucceeded = true
            break
        end
        sleep(2)
        if i % 10 == 0
            @info "Polling for: $(setdiff(testFactorLabels,actualFactorLabels))"
        end
    end
    if !factorAddSucceeded return false end
    for i in 1:size(testFactorLabels)[1]
        actualFactor = getFactor(client,context,testFactorLabels[i])
        if !(actualFactor["label"] == testFactorLabels[i])
            return false
        end
        if !(actualFactor["fnctype"] == testFactorTypes[i])
            return false
        end
    end
    return true
end

function testGetFactors(apiUrl, userId, robotId, sessionId)
    client = NavAbilityHttpsClient(apiUrl)
    context = Client(userId,robotId,sessionId)
    testVariableLabels = ["x0", "x1"]
    testVariableTypes = ["RoME.Pose2","RoME.Pose2"]
    addVariable(client,context,Variable(testVariableLabels[1], testVariableTypes[1]))
    addVariable(client,context,Variable(testVariableLabels[2], testVariableTypes[2]))
    variableAddSucceeded = false
    for i in 1:MAX_POLLING_TRIES
        actualVariableLabels = ls(client,context)
        if setdiff(testVariableLabels,actualVariableLabels) == []
            variableAddSucceeded = true
            break
        end
        sleep(2)
        if i % 10 == 0
            @info "Polling for: $(setdiff(testVariableLabels,actualVariableLabels))"
        end
    end
    if !variableAddSucceeded return false end
    testFactorLabels = ["x0x1f1","x0f1"]
    testFactorTypes = ["Pose2Pose2","PriorPose2"]
    addFactor(client,context,Factor(testFactorLabels[1], testFactorTypes[1], testVariableLabels, Pose2Pose2Data()))
    addFactor(client,context,Factor(testFactorLabels[2], testFactorTypes[2], [testVariableLabels[1]], PriorPose2Data()))
    factorAddSucceeded = false
    for i in 1:MAX_POLLING_TRIES
        actualFactorLabels = lsf(client,context)
        if setdiff(testFactorLabels,actualFactorLabels) == []
            factorAddSucceeded = true
            break
        end
        sleep(2)
        if i % 10 == 0
            @info "Polling for: $(setdiff(testFactorLabels,actualFactorLabels))"
        end
    end
    if !factorAddSucceeded return false end

    factors = getFactors(client,context;detail=FULL)
    for f in factors
        if !haskey(f,"label") || !haskey(f,"fnctype")
            return false
        end
        if f["label"] == "x0x1f1" && !(f["fnctype"] == "Pose2Pose2")
            return false
        end
        if f["label"] == "x0f1" && !(f["fnctype"] == "PriorPose2")
            return false
        end
    end
    return true
end

function RunTests(apiUrl, userId, robotId, sessionId)
    @testset "factor-testset" begin
        @info "Running factor-testset"

        @test testAddFactor(apiUrl, userId, robotId, sessionId*"_testAddFactor")
        @test testLsf(apiUrl, userId, robotId, sessionId*"_testLsf")
        @test testGetFactor(apiUrl, userId, robotId, sessionId*"_testGetFactor")
        @test testGetFactors(apiUrl, userId, robotId, sessionId*"_testGetFactors")
    end
end

end