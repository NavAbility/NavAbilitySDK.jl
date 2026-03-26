# Test Variable CRUD operations

@testset "Add and get variables" begin
    v1 = addVariable!(fgclient, VariableDFG(:a, TestPosition1(); tags = Set([:VARIABLE, :POSE]), solvable = 0))
    @test v1.label == :a

    v2 = addVariable!(fgclient, VariableDFG(:b, TestPosition1(); tags = Set([:VARIABLE, :LANDMARK]), solvable = 1))
    @test v2.label == :b

    g_v1 = getVariable(fgclient, :a)
    @test g_v1 == v1

    g_v2 = getVariable(fgclient, :b)
    @test g_v2 == v2
end

@testset "Get variable summary and skeleton" begin
    @test getVariableSummary(fgclient, :a).label == :a
    @test getVariableSkeleton(fgclient, :a).label == :a
    @test length(getVariablesSkeleton(fgclient)) == 2
    @test length(getVariablesSummary(fgclient)) == 2
end

@testset "List variables" begin
    @test issetequal(listVariables(fgclient), [:a, :b])
    @test issetequal(listVariables(fgclient; solvableFilter = >=(0)), [:a, :b])
    @test listVariables(fgclient; solvableFilter = >=(1)) == [:b]
end

@testset "Get variables batch" begin
    vars = getVariables(fgclient)
    @test length(vars) == 2

    vars_by_label = getVariables(fgclient, [:a])
    @test length(vars_by_label) == 1
    @test vars_by_label[1].label == :a
end

@testset "Variable errors" begin
    @test_throws DFG.LabelNotFoundError getVariable(fgclient, :nonexistent)
    # Adding a variable that already exists should throw LabelExistsError
    @test_throws DFG.LabelExistsError addVariable!(fgclient, VariableDFG(:a, TestPosition1()))
end

@testset "Add variables in batch" begin
    batch_vars = [VariableDFG(Symbol("batch_$i"), TestPosition1()) for i in 1:5]
    result = addVariables!(fgclient, batch_vars)
    @test length(result) == 5
    @test all(v -> v.label in [Symbol("batch_$i") for i in 1:5], result)
end
