# Test Agent and Graph CRUD operations

@testset "Create and list agents" begin
    tmp_agentLabel = Symbol("TmpAgent_", randstring(4))
    agent = addAgent!(client, DFG.Agent(; label = tmp_agentLabel))
    @test NvaSDK.getAgent(client, tmp_agentLabel) == agent
    @test agent.label == tmp_agentLabel
    @test tmp_agentLabel in listAgents(client)

    deleteAgent!(client, tmp_agentLabel)
    @test !(tmp_agentLabel in listAgents(client))
end

@testset "Create and list graphs" begin
    tmp_graphLabel = Symbol("TmpGraph_", randstring(4))
    graph = addGraph!(client, tmp_graphLabel)
    @test graph.label == tmp_graphLabel
    @test tmp_graphLabel in listGraphs(client)

    con_res = NvaSDK.connect!(client, NvaSDK.getAgent(client, TEST_AGENT_LABEL), graph)

    # Create a temporary fgclient for deletion (no variables/factors)
    tmp_fgclient = NavAbilityDFG(client, tmp_graphLabel, TEST_AGENT_LABEL)

    # connect to NvaDFG just created, also verifies graph linked to agent
    @test NavAbilityDFG(client, tmp_graphLabel) == tmp_fgclient

    deleteGraph!(tmp_fgclient)
    @test !(tmp_graphLabel in listGraphs(client))

end

@testset "Agent Bloblets" begin
    # Agent bloblets replace the old metadata API
    tmp_agentLabel = Symbol("TmpBloblet_", randstring(4))
    addAgent!(client, DFG.Agent(; label = tmp_agentLabel))

    bloblet = DFG.Bloblet(:mykey, "myvalue")
    addAgentBloblet!(client, tmp_agentLabel, bloblet)

    bloblets = getAgentBloblets(client, tmp_agentLabel)
    @test length(bloblets) >= 1
    @test any(b -> b.label == :mykey && b.val == "myvalue", bloblets)

    # Also test via fgclient
    tmp_graphLabel = Symbol("TmpBlobletG_", randstring(4))
    addGraph!(client, tmp_graphLabel)
    tmp_fgclient = NavAbilityDFG(client, tmp_graphLabel, tmp_agentLabel)

    bloblet2 = DFG.Bloblet(:otherkey, 42)
    addAgentBloblet!(tmp_fgclient, bloblet2)
    bloblets2 = getAgentBloblets(tmp_fgclient)
    @test any(b -> b.label == :otherkey, bloblets2)

    deleteGraph!(tmp_fgclient)
    deleteAgent!(client, tmp_agentLabel)
end
