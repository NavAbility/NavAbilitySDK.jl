
function testAddFactor(client, context, factorLabels, factorTypes, factorVariables, factorData)
    resultIds = String[]
    for (index, label) in enumerate(factorLabels)
        resultId = addFactor(client,context,Factor(label, factorTypes[index], factorVariables[index], factorData[index]))
        @test resultId != "Error"
        push!(resultIds, resultId)
    end
    
    waitForCompletion(client, resultIds, expectedStatuses=["Complete"])
    return resultIds
end

function testLsf(client, context, factorLabels, factorTypes)
    @show setdiff(factorLabels, lsf(client, context))
    @test setdiff(factorLabels, lsf(client, context)) == []
end

function testGetFactor(client, context, factorLabels, factorTypes)
    for i in 1:length(factorLabels)
        actualFactor = getFactor(client,context,factorLabels[i])
        @test actualFactor["label"] == factorLabels[i]
        @test actualFactor["fnctype"] == factorTypes[i]
    end
end

function testGetFactors(client, context, factorLabels, factorTypes)
    # Make a quick dictionary of the expected variable Types
    factorIdType = Dict(factorLabels .=> factorTypes)

    factors = getFactors(client, context; detail=SUMMARY)
    for f in factors
        @test f["fnctype"] == factorIdType[f["label"]]
    end
end

function runFactorTests(client, context)
    @testset "factor-testset" begin
        @info "Running factor-testset"

        # TODO: Refactor as a dictionary, or just do most of this in addFactor.
        factorLabels = ["x0x1f1","x0f1"]
        factorTypes = ["Pose2Pose2","PriorPose2"]
        factorVariables = [["x0", "x1"], ["x0"]]
        factorData = [Pose2Pose2Data(), PriorPose2Data()]

        @test testAddFactor(client, context, factorLabels, factorTypes, factorVariables, factorData)
        @test testLsf(client, context, factorLabels, factorTypes)
        @test testGetFactor(client, context, factorLabels, factorTypes)
        @test testGetFactors(client, context, factorLabels, factorTypes)
    end
end