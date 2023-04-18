#Test adapted from DFG's iifInterfaceTests
using NavAbilitySDK
using Test
using JSON3
using LinearAlgebra
using Random
using UUIDs

apiUrl = get(ENV, "API_URL", "https://api.d1.navability.io")
userLabel = get(ENV, "USER_ID", "guest@navability.io")
robotLabel = get(ENV, "ROBOT_ID", "TestRobot")
sessionLabel = get(ENV, "SESSION_ID", "TestSession_$(randstring(4))")
# sessionLabel = "TestSession_RG94"

@testset "Create fg client" begin
    client = NvaSDK.NavAbilityClient(apiUrl)
    global fgclient = NvaSDK.DFGClient(
        client,
        userLabel,
        robotLabel,
        sessionLabel;
        addRobotIfNotExists = true,
        addSessionIfNotExists = true,
    )
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
    @test_broken issetequal([:a, :b], listVariables(fgclient, solvable=0))
    @test_broken listVariables(fgclient, solvable=1) == [:b]
    @test_broken map(v->v.label, getVariables(fgclient, solvable=1)) == [:b]
    @test_broken listFactors(fgclient, solvable=1) == []
    @test_broken listFactors(fgclient, solvable=0) == [:abf1]
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

end

# Gets
@testset "testing some crud" begin
    global fgclient,v1,v2,f1
    @test getVariable(fgclient, v1.label) == v1
    @test getFactor(fgclient, f1.label) == f1
    @test_throws Exception getVariable(fgclient, :nope)
    @test_throws Exception getVariable(fgclient, "nope")
    @test_throws Exception getFactor(fgclient, :nope)
    @test_throws Exception getFactor(fgclient, "nope")

    #spot check summaries and skeleton
    @test getVariableSummary(fgclient, :a).label == v1.label
    @test getVariableSkeleton(fgclient, :a).label == v1.label

    @test length(getVariablesSkeleton(fgclient)) == 2
    @test length(getVariablesSummary(fgclient)) == 2
    @test length(getVariables(fgclient)) == 2
    
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
    u_par_vnd = updateVariableSolverData!(fgclient, par_vnd)
    @test u_par_vnd.covar == [1.1]

    d_vnd = deleteVariableSolverData!(fgclient, par_vnd)

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
        mimeType = ""
    )

    de2 = BlobEntry(
        originId = uuid4(),
        blobId = uuid4(),
        label = :key2,
        blobstore = :test,
        hash = "",
        origin = "",
        description = "",
        mimeType = ""
    )

    de2_update = BlobEntry(
        originId = uuid4(),
        blobId = uuid4(),
        label = :key2,
        blobstore = :test,
        hash = "",
        origin = "",
        description = "",
        mimeType = "image/jpg"
    )

    #add
    a_de1 = addBlobEntry!(fgclient, :a, de1)
    a_de2 = addBlobEntry!(fgclient, :a, de2)

    #get
    @test a_de1 == getBlobEntry(fgclient, :a, :key1)
    @test a_de2 == getBlobEntry(fgclient, :a, :key2)
    @test a_de2 in getBlobEntries(fgclient, :a)

    # FIXME should not throw bounds error but KeyError
    @test_throws Exception getBlobEntry(fgclient, :b, :key1)

    #update
    @test_broken updateBlobEntry!(fgclient, :a, de2_update) == de2_update
    
    #list
    entries = getBlobEntries(fgclient, :a)
    @test length(entries) == 2
    @test issetequal(map(e->e.label, entries), [:key1, :key2])
    
    @test issetequal(listBlobEntries(fgclient, :a), [:key1, :key2])
    
    #delete
    # @test deleteBlobEntry!(fgclient, :a, :key1) == a_de1
    @test_broken deleteBlobEntry!(fgclient, :a, :key1)
    @test_broken listBlobEntries(fgclient, :a) == Symbol[:key2]
    #delete from ddfg
    @test_broken deleteBlobEntry!(fgclient, :a, :key2)
    @test_broken listBlobEntries(fgclient, :a) == Symbol[]

    #Testing session blob entries
    a_de = addSessionBlobEntries!(fgclient, [de1])[1]
    g_de = getSessionBlobEntry(fgclient, :key1)
    @test a_de == g_de
    @test listSessionBlobEntries(fgclient) == [:key1]


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
    @test ppe2 != updatePPE!(fgclient, ppe2)

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
vars = map(n -> Variable(Symbol("x$n"), "Position{1}", tags = [:POSE]), 1:numNodes)
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
    n -> Factor( 
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

    @test listVariableNeighbors(fgclient, :x1) == [facts[1].label]
    neighbors = listFactorNeighbors(fgclient, facts[1].label)
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

# batch delete
#TODO deleteVariables
#TODO deleteFactors
