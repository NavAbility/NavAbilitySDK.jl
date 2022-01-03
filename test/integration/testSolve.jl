module TestSolve

using Test

include("../../src/NavAbilitySDK.jl")
using .NavAbilitySDK

MAX_POLLING_TRIES = 150

function testSolveSession(apiUrl, userId, robotId, sessionId)
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
    function validatePPEs(variable)::Bool
        ppes = get(variable, "ppes", nothing)
        if ppes === nothing return false end
        if size(ppes)[1] < 1 return false end
        return true
    end
    solveSession(client,context)
    successfullySolved = false
    for i in 1:MAX_POLLING_TRIES
        variables = getVariables(client,context)
        if all([validatePPEs(v) for v in variables])
            successfullySolved = true
            break
        end
        sleep(15)
        if i % 10 == 0
            @info "Polling for ppes..." 
        end
    end
    if !successfullySolved throw("Failed to solve.") end
    return true
end

function RunTests(apiUrl, userId, robotId, sessionId)
    @testset "solve-testset" begin
        @info "Running solve-testset"

        @test testSolveSession(apiUrl, userId, robotId, sessionId*"_testSolveSession")
    end
end

end