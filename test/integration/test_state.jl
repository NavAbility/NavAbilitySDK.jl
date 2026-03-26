# Test State CRUD operations

@testset "Add state" begin
    vnd = State{TestPosition1}(; label = :parametric)
    a_vnd = addState!(fgclient, :a, vnd)
    @test a_vnd.label == :parametric
end

@testset "List states" begin
    states = listStates(fgclient, :a)
    @test states isa Vector{Symbol}
    @test :parametric in states
end

@testset "Get all states" begin
    all_states = getStates(fgclient, :a)
    @test all_states isa Vector
    @test length(all_states) >= 1
end

@testset "Get state" begin
    state = getState(fgclient, :a, :parametric)
    @test state isa State
    @test state.label == :parametric
end

@testset "Merge state" begin
    vnd = getState(fgclient, :a, :parametric)
    vnd.solves = 42
    u_vnd = mergeState!(fgclient, :a, vnd)
    @test u_vnd.solves == 42
end

@testset "Delete state" begin
    vnd = State{TestPosition1}(; label = :todelete)
    addState!(fgclient, :a, vnd)
    d_vnd = deleteState!(fgclient, :a, :todelete)
    @test !(:todelete in listStates(fgclient, :a))
end
