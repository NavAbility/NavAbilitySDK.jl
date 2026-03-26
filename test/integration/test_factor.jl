# Test Factor CRUD operations

# Store factor labels for use in later test files (labels have random suffixes)
const factor_labels = Dict{Symbol, Symbol}()

@testset "Add and get factors" begin
    f1 = addFactor!(fgclient, FactorDFG([:a, :b], TestRelative1(); solvable = 0))
    factor_labels[:rel] = f1.label
    @test startswith(string(f1.label), "ab_f")

    f0 = addFactor!(fgclient, FactorDFG([:a], TestPrior1(); tags = Set([:FACTOR, :PRIOR])))
    factor_labels[:prior] = f0.label
    @test startswith(string(f0.label), "a_f")

    @test_throws DFG.LabelExistsError addFactor!(fgclient, f0)

    g_f1 = getFactor(fgclient, f1.label)
    @test g_f1.label == f1.label

    g_f0 = getFactor(fgclient, f0.label)
    @test g_f0.label == f0.label

    @test deleteFactor!(fgclient, f0.label) == 1
    @test !hasFactor(fgclient, f0.label)
    @test deleteFactor!(fgclient, f1) == 1

    @test addFactors!(fgclient, [f0, f1]) == [f0, f1]
    g_facs = getFactors(fgclient)
    @test length(g_facs) == 2

end

@testset "List and get factors" begin
    fac_list = listFactors(fgclient)
    @test factor_labels[:rel] in fac_list
    @test factor_labels[:prior] in fac_list
    @test length(getFactors(fgclient)) >= 2
    @test length(getFactorsSkeleton(fgclient)) == 2
    @test length(DFG.getFactorsSummary(fgclient)) == 2
    @test DFG.getFactorSkeleton(fgclient, factor_labels[:rel]).label == factor_labels[:rel]
    @test DFG.getFactorSummary(fgclient, factor_labels[:rel]).label == factor_labels[:rel]
end

@testset "Factor errors" begin
    @test_throws DFG.LabelNotFoundError getFactor(fgclient, :nonexistent)
    @test_throws DFG.LabelNotFoundError getFactor(fgclient, :definitely_not_a_factor)
end
