
function testAddFactor(client, context, factorLabels, factorTypes, factorVariables, factorData)
    resultIds = Task[]
    for (index, label) in enumerate(factorLabels)
        resultId = addFactor(client,context,Factor(label, factorTypes[index], factorVariables[index], factorData[index]))
        @test resultId != "Error"
        push!(resultIds, resultId)
    end

    waitForCompletion(client, resultIds; expectedStatuses=["Complete"])
    return resultIds
end

function testLsf(client, context, factorLabels, factorTypes)
    @test setdiff(factorLabels, fetch( lsf(client, context) )) == []
end

function testGetFactor(client, context, factorLabels, factorTypes)
    for i in 1:length(factorLabels)
        actualFactor = fetch( getFactor(client,context,factorLabels[i]) )
        @test actualFactor["label"] == factorLabels[i]
        @test actualFactor["fnctype"] == factorTypes[i]
    end
end

function testGetFactors(client, context, factorLabels, factorTypes)
    # Make a quick dictionary of the expected variable Types
    factorIdType = Dict(factorLabels .=> factorTypes)

    factors = fetch( getFactors(client, context, detail=FULL) )
    for f in factors
        @test f["fnctype"] == factorIdType[f["label"]]
    end
end

function testDeleteFactor(client, context, factorLabels)

    resultId = fetch(addFactor(client,context,Factor("x0x1f_oops", "Pose2Pose2", ["x0", "x1"], Pose2Pose2Data())))
    @test resultId != "Error"

    waitForCompletion(client, [resultId], expectedStatuses=["Complete"])
    
    @show resultId = fetch(deleteFactor(client, context, "x0x1f_oops"))
    
    @test NVA.waitForCompletion2(client, resultId)

    @test setdiff(factorLabels, fetch( lsf(client, context) )) == []

    return nothing
end

function runFactorTests(client, context)
    @testset "factor-testset" begin
        @info "Running factor-testset"

        # TODO: Refactor as a dictionary, or just do most of this in addFactor.
        factorLabels = ["x0x1f1","x0f1"]
        factorTypes = ["Pose2Pose2","PriorPose2"]
        factorVariables = [["x0", "x1"], ["x0"]]
        factorData = [Pose2Pose2Data(), PriorPose2Data()]

        @testset "Adding" begin testAddFactor(client, context, factorLabels, factorTypes, factorVariables, factorData) end
        @testset "Listing" begin testLsf(client, context, factorLabels, factorTypes) end
        @testset "Getting" begin testGetFactor(client, context, factorLabels, factorTypes) end
        @testset "Getting Lists" begin testGetFactors(client, context, factorLabels, factorTypes) end
        @testset "Delete" begin testDeleteFactor(client, context, factorLabels) end

    end
end