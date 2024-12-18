#Test adapted from DFG's iifInterfaceTests
using NavAbilitySDK
using Test
using JSON3
using LinearAlgebra
using Random
using UUIDs

apiUrl = get(ENV, "API_URL", "https://api.navability.io")
orgLabel = Symbol(ENV["ORG_LABEL"])
agentLabel = :TestRobot
fgLabel = Symbol("TestSession_", randstring(7))
auth_token = ENV["AUTH_TOKEN"]

@testset "Create fg client" begin
    global client = NavAbilityClient(auth_token, apiUrl; orgLabel)
    global fgclient = NavAbilityDFG(
        client,
        fgLabel,
        agentLabel;
        addAgentIfAbsent = true,
        addGraphIfAbsent = true,
    )
    #just trigger show to check for error
    display(fgclient)

    # test easy constructor
    fgclient2 = NavAbilityDFG(auth_token, fgLabel, agentLabel; apiUrl, orgLabel)
    @test fgclient.fg == fgclient2.fg
    @test fgclient.agent == fgclient2.agent
    @test fgclient.client.id == fgclient2.client.id
end

@testset "Agent and Graph" begin
    temp_robotLabel = Symbol("TestRobot_", randstring(4))
    temp_sessionLabel = Symbol("TestSession_", randstring(4))

    robot = addAgent!(client, temp_robotLabel)
    @test robot.label == temp_robotLabel

    @test temp_robotLabel in listAgents(client)

    session = addGraph!(client, temp_sessionLabel)
    @test session.label == temp_sessionLabel

    @test temp_sessionLabel in listGraphs(client)

    tmp_fgclient = NavAbilityDFG(client, temp_sessionLabel, temp_robotLabel)
    deleteGraph!(tmp_fgclient)
    @test !(temp_sessionLabel in listGraphs(client))

    deleteAgent!(client, temp_robotLabel)
    @test !(temp_robotLabel in listAgents(client))

end

# Building simple graph...
@testset "Building a simple Graph" begin
    global fgclient,v1,v2,f1
    # Use IIF to add the variables and factors
    v1 = addVariable!(fgclient, :a, "Position{1}", tags = [:POSE], solvable=0)
    v2 = addVariable!(fgclient, :b, "Position{1}", tags = [:LANDMARK], solvable=1)
    f1 = addFactor!(fgclient, [:a; :b], NvaSDK.LinearRelative(NvaSDK.Normal(50.0,2.0)), solvable=0)
end

@testset "Listing Nodes" begin
    global fgclient,v1,v2,f1
    @test length(listVariables(fgclient)) == 2
    @test length(listFactors(fgclient)) == 1 # Unless we add the prior!
    @test issetequal([:a, :b], listVariables(fgclient))
    @test listFactors(fgclient) == [f1.label] # Unless we add the prior!
    # Additional testing for https://github.com/JuliaRobotics/DistributedFactorGraphs.jl/issues/201
    @test issetequal([:a, :b], listVariables(fgclient, solvable=0))
    @test listVariables(fgclient, solvable=1) == [:b]
    @test_broken map(v->v.label, getVariables(fgclient, solvable=1)) == [:b]
    @test listFactors(fgclient, solvable=1) == []
    @test contains(string(listFactors(fgclient, solvable=0)[1]), "abf")
    @test_broken map(f->f.label, getFactors(fgclient, solvable=0)) == [:abf1]
    @test_broken map(f->f.label, getFactors(fgclient, solvable=1)) == []
    #
    # @test lsf(fgclient, :a) == [f1.label]
    # Tags
    # @test ls(fgclient, tags=[:POSE]) == [:a]
    # @test symdiff(ls(fgclient, tags=[:POSE, :LANDMARK]), ls(fgclient, tags=[:VARIABLE])) == []
    # Regexes
    # @test ls(fgclient, r"a") == [v1.label]
    # TODO: Check that this regular expression works on everything else!
    # it works with the .
    # @test lsf(fgclient, r"abf.*") == [f1.label]

    # Existence
    @test exists(fgclient, :a)
    # @test exists(fgclient, v1)
    @test exists(fgclient, :nope) == false
    # isFactor and isVariable
    # @test isFactor(fgclient, f1.label)
    # @test !isFactor(fgclient, v1.label)
    # @test isVariable(fgclient, v1.label)
    # @test !isVariable(fgclient, f1.label)
    # @test !isVariable(fgclient, :doesntexist)
    # @test !isFactor(fgclient, :doesntexist)

    # @test getFactorType(f1.solverData) === f1.solverData.fnc.usrfnc!
    # @test getFactorType(f1) === f1.solverData.fnc.usrfnc!
    # @test getFactorType(fgclient, :abf1) === f1.solverData.fnc.usrfnc!

    # @test !isPrior(fgclient, :abf1) # f1 is not a prior
    # @test lsfPriors(fgclient) == []
    # #FIXME don't know what it is supposed to do
    # @test_broken lsfTypes(fgclient)

    # varNearTs = findVariableNearTimestamp(fgclient, now())
    # @test_skip varNearTs[1][1]  == [:b]

    @test findVariableNearTimestamp(fgclient, v1.timestamp, NvaSDK.Dates.Millisecond(1)) == [:a]

end

# Gets
@testset "getVariable and getFactor" begin
    global fgclient,v1,v2,f1
    @test getVariable(fgclient, v1.label) == v1
    @test getFactor(fgclient, f1.label) == f1
    @test_throws KeyError getVariable(fgclient, :nope)
    @test_throws Exception getVariable(fgclient, "nope")
    @test_throws KeyError getFactor(fgclient, :nope)
    @test_throws Exception getFactor(fgclient, "nope")

    #spot check summaries and skeleton
    @test getVariableSummary(fgclient, :a).label == v1.label
    @test getVariableSkeleton(fgclient, :a).label == v1.label

    @test length(getVariablesSkeleton(fgclient)) == 2
    @test length(getVariablesSummary(fgclient)) == 2
    @test length(getVariables(fgclient)) == 2
    @test getVariables(fgclient, [:a]) == [v1]
    
    @test length(getFactorsSkeleton(fgclient)) == 1
    @test length(getFactors(fgclient)) == 1
    
    # Sets
    # v1Prime = deepcopy(v1)
    # @test updateVariable!(fgclient, v1Prime) == v1 #Maybe move to crud
    # @test updateVariable!(fgclient, v1Prime) == getVariable(fgclient, v1.label)
    # f1Prime = deepcopy(f1)
    # @test updateFactor!(fgclient, f1Prime) == f1 #Maybe move to crud
    # @test updateFactor!(fgclient, f1Prime) == getFactor(fgclient, f1.label)
end

@testset "VariableSolverData" begin
    global fgclient,v1,v2,f1
    # Solver Data
    vnd = NvaSDK.PackedVariableNodeData(nothing, [0.0], 1, [0.0], 1, Symbol[], Int64[], 1, false, :NOTHING, Symbol[], "IncrementalInference.Position{1}", false, [0.0], false, false, 0, 0, :parametric, Float64[], "0.21.0")
    par_vnd = addVariableSolverData!(fgclient, :a, vnd)
    
    vnd = NvaSDK.PackedVariableNodeData(nothing, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0], 1, [0.0], 1, Symbol[], Int64[], 1, false, :NOTHING, Symbol[], "IncrementalInference.Position{1}", false, [0.0], false, false, 0, 0, :default, Float64[], "0.21.0")
    def_vnd = addVariableSolverData!(fgclient, :a, vnd)
    
    @test getVariableSolverData(fgclient, :a) ==  def_vnd
    @test getVariableSolverData(fgclient, :a, :parametric) ==  par_vnd

    @test issetequal(listVariableSolverData(fgclient, :a), [:default, :parametric])

    @test length(getVariableSolverDataAll(fgclient, :a)) == 2

    # change some things and update
    push!(par_vnd.covar, 1.1)
    u_par_vnd = updateVariableSolverData!(fgclient, :a, par_vnd)
    @test u_par_vnd.covar == [1.1]

    d_vnd = deleteVariableSolverData!(fgclient, :a, par_vnd)

    @test listVariableSolverData(fgclient, :a) == [:default]

end

@testset "Data Entries" begin
    
    de1 = BlobEntry(
        originId = uuid4(),
        blobId = uuid4(),
        label = :key1,
        blobstore = :test,
        hash = "",
        origin = "",
        description = "",
        mimeType = "",
        size = "10",
    )

    de2 = BlobEntry(
        originId = uuid4(),
        blobId = uuid4(),
        label = :key2,
        blobstore = :test,
        hash = "",
        origin = "",
        description = "",
        mimeType = "",
        size="100",
    )

    de2_update = BlobEntry(
        originId = uuid4(),
        blobId = uuid4(),
        label = :key2,
        blobstore = :test,
        hash = "",
        origin = "",
        description = "",
        mimeType = "image/jpg",
        size="101",
    )

    #add
    a_de1 = addBlobEntry!(fgclient, :a, de1)
    a_de2 = addBlobEntry!(fgclient, :a, de2)

    #get
    @test a_de1 == getBlobEntry(fgclient, :a, :key1)
    @test a_de2 == getBlobEntry(fgclient, :a, :key2)
    @test a_de2 in getBlobEntries(fgclient, :a)

    @test_throws KeyError getBlobEntry(fgclient, :b, :key1)

    #update
    #TODO updateBlobEntry! not implemented
    @test_broken updateBlobEntry!(fgclient, :a, de2_update) == de2_update
    
    #list
    entries = getBlobEntries(fgclient, :a)
    @test length(entries) == 2
    @test issetequal(map(e->e.label, entries), [:key1, :key2])
    
    @test issetequal(listBlobEntries(fgclient, :a), [:key1, :key2])
    
    #delete
    # @test deleteBlobEntry!(fgclient, :a, :key1) == a_de1
    @test deleteBlobEntry!(fgclient, :a, :key1).label == :key1
    @test listBlobEntries(fgclient, :a) == Symbol[:key2]
    #delete from ddfg
    @test deleteBlobEntry!(fgclient, :a, :key2).label == :key2
    @test listBlobEntries(fgclient, :a) == Symbol[]

    #Testing session blob entries
    a_de = NvaSDK.addGraphBlobEntries!(fgclient, [de1])[1]
    g_de = getGraphBlobEntry(fgclient, :key1)
    @test a_de == g_de
    @test listGraphBlobEntries(fgclient) == [:key1]


end

@testset "PPEs" begin
    global fgclient
    #get the variable
    var1 = getVariable(fgclient, :a)
    #make a copy and simulate external changes
    ppe = addPPE!(fgclient, :a, MeanMaxPPE(:default, [150.0], [100.0], [50.0]))

    #Check if variable is updated
    @test ppe == getPPE(fgclient, :a)

    # Add a new estimate.
    ppe2 = addPPE!(fgclient, :a, MeanMaxPPE(:second, [15.0], [10.0], [5.0]))

    @test ppe2 == getPPE(fgclient, :a, :second)

    @test issetequal(listPPEs(fgclient, :a), [:default, :second])

    @test length(getPPEs(fgclient, :a)) == 2
    
    # Delete :default and replace to see if new ones can be added
    deletePPE!(fgclient, :a, :default)

    #confirm delete
    @test listPPEs(fgclient, :a) == [:second]
    
    #if its added agian the id should be ignored and a new one generated
    a_ppe = addPPE!(fgclient, :a, ppe)
    @test a_ppe != ppe

    # modify ppe2 
    ppe2.mean[] = 5.5
    # they are no longer the same because of updated timestamp
    @test ppe2 != updatePPE!(fgclient, :a, ppe2)

end

# at this stage v has blob entries, solver data and ppes
@testset "addVariable with satelite" begin
    va = getVariable(fgclient, :a)
    vc = VariableDFG(;
        (k => getproperty(va, k) for k in fieldnames(VariableDFG))...,
        id=nothing,
        label=:c
    )
    a_vc = addVariable!(fgclient, vc)
    g_vc = getVariable(fgclient, :c)
    #order of vector is not maintained so can't do @test a_vc == g_vc so so doing spot check
    @test length(g_vc.ppes) == 2
    @test g_vc.solverData == a_vc.solverData
    @test getBlobEntry(a_vc, :key1) == getBlobEntry(g_vc, :key1)
    @test a_vc.id == g_vc.id

    del = deleteVariable!(fgclient, :c)
    # @test del["deleteVariables"]["nodesDeleted"] == 6

end

# Deletions
@testset "Deletions" begin
    global fgclient, v1, v2, f1
    deleteFactor!(fgclient, f1)
    @test listFactors(fgclient) == []
    deleteVariable!(fgclient, v1)
    @test listVariables(fgclient) == [:b]
    deleteVariable!(fgclient, v2)
    @test listVariables(fgclient) == []    
end


# Now make a complex graph for connectivity tests
numNodes = 10
#change solvable and solveInProgress for x7,x8 for improved tests on x7x8f1
vars = map(n -> VariableDFG(Symbol("x$n"), "Position{1}", tags = [:POSE]), 1:numNodes)
#add vars in batch 
addVariables!(fgclient, vars)

# TODO this will need update variable
# setSolvable!(verts[7], 1)
# setSolvable!(verts[8], 0)
# getSolverData(verts[8]).solveInProgress = 1
# #call update to set it on cloud
# updateVariable!(fgclient, verts[7])
# updateVariable!(fgclient, verts[8])

facts = map(
    n -> FactorDFG( 
        [vars[n].label, vars[n+1].label],
        NvaSDK.LinearRelative(NvaSDK.Normal(50.0,2.0));
        solvable=0
    ), 
    1:(numNodes-1)
)

#TODO add factors in batch
a_facts = addFactor!.(fgclient, facts)

@testset "Getting Neighbors" begin
    global fgclient,vars,facts
    # Get neighbors tests
    @test listNeighbors(fgclient, :x1) == [facts[1].label]
    neighbors = listNeighbors(fgclient, facts[1].label)
    @test issetequal(neighbors, [:x1, :x2])

    @test listNeighbors(fgclient, :x1) == [facts[1].label]
    neighbors = listNeighbors(fgclient, facts[1].label)
    @test issetequal(neighbors, [:x1, :x2])

    # Testing aliases
    # @test getNeighbors(fgclient, getFactor(fgclient, :x1x2f1)) == ls(fgclient, getFactor(fgclient, :x1x2f1))
    # @test getNeighbors(fgclient, :x1x2f1) == ls(fgclient, :x1x2f1)

    # # solvable checks
    # @test getNeighbors(fgclient, :x5, solvable=1) == Symbol[]
    # @test symdiff(getNeighbors(fgclient, :x5, solvable=0), [:x4x5f1,:x5x6f1]) == []
    # @test symdiff(getNeighbors(fgclient, :x5),[:x4x5f1,:x5x6f1]) == []
    # @test getNeighbors(fgclient, :x7x8f1, solvable=0) == [:x7, :x8]
    # @test getNeighbors(fgclient, :x7x8f1, solvable=1) == [:x7]
    # @test getNeighbors(fgclient, verts[1], solvable=0) == [:x1x2f1]
    # @test getNeighbors(fgclient, verts[1], solvable=1) == Symbol[]
    # @test getNeighbors(fgclient, verts[1]) == [:x1x2f1]

end

deleteFactor!.(fgclient, getFactorsSkeleton(fgclient))
deleteVariable!.(fgclient, listVariables(fgclient))
deleteGraph!(fgclient)
# batch delete
#TODO deleteVariables
#TODO deleteFactors
