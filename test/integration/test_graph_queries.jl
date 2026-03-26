# Test graph structure queries: neighbors, hasVariable/hasFactor, filtering

@testset "HasVariable and HasFactor" begin
    @test hasVariable(fgclient, :a)
    @test hasVariable(fgclient, :b)
    @test !hasVariable(fgclient, :nonexistent)
    @test hasFactor(fgclient, factor_labels[:rel])
    @test !hasFactor(fgclient, :nonexistent)
    @test !hasVariable(fgclient, factor_labels[:rel])
    @test !hasFactor(fgclient, :a)
    @test DFG.exists(fgclient, :a)
    @test DFG.exists(fgclient, factor_labels[:rel])
end

@testset "List neighbors" begin
    a_neighbors = listNeighbors(fgclient, :a)
    @test factor_labels[:rel] in a_neighbors
    @test factor_labels[:prior] in a_neighbors

    rel_neighbors = listNeighbors(fgclient, factor_labels[:rel])
    @test issetequal(rel_neighbors, [:a, :b])
end

@testset "List with regex filter" begin
    @test :a in listVariables(fgclient, r"^a$")
    @test all(l -> startswith(string(l), "batch_"), listVariables(fgclient, r"batch"))
end

@testset "List with tag filter" begin
    @test :a in listVariables(fgclient; tags = [:POSE])
    @test :b in listVariables(fgclient; tags = [:LANDMARK])
end

@testset "Find variable near timestamp" begin
    v1 = getVariable(fgclient, :a)
    result = findVariablesNearTimestamp(fgclient, v1.timestamp, Dates.Millisecond(1))
    @test :a in result
end
