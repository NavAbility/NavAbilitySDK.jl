# Test Blob Entry CRUD operations on variables, graph, and agent

@testset "Variable Blobentries" begin
    de1 = Blobentry(; blobid = uuid4(), label = :key1, blobstore = :test)
    de2 = Blobentry(; blobid = uuid4(), label = :key2, blobstore = :test)

    # Add
    a_de1 = addVariableBlobentry!(fgclient, :a, de1)
    a_de2 = addVariableBlobentry!(fgclient, :a, de2)

    # Get
    @test a_de1 == getVariableBlobentry(fgclient, :a, :key1)
    @test a_de1.label == :key1
    @test a_de2.label == :key2
    @test a_de2.label in map(e -> e.label, getVariableBlobentries(fgclient, :a))

    # List
    entries = getVariableBlobentries(fgclient, :a)
    @test length(entries) >= 2
    entry_labels = map(e -> e.label, entries)
    @test :key1 in entry_labels
    @test :key2 in entry_labels
    @test issubset([:key1, :key2], listVariableBlobentries(fgclient, :a))

    # Delete
    @test deleteVariableBlobentry!(fgclient, :a, :key1) == 1
    @test !(:key1 in listVariableBlobentries(fgclient, :a))
    @test deleteVariableBlobentry!(fgclient, :a, :key2) == 1
    @test isempty(listVariableBlobentries(fgclient, :a))
end

@testset "Graph Blobentries" begin
    de1 = Blobentry(; blobid = uuid4(), label = :gkey1, blobstore = :test)

    a_de = addGraphBlobentries!(fgclient, [de1])[1]
    g_de = getGraphBlobentry(fgclient, :gkey1)
    @test a_de == g_de

    @test a_de.label == :gkey1
    @test :gkey1 in listGraphBlobentries(fgclient)
    @test a_de.label in map(e -> e.label, getGraphBlobentries(fgclient))
    @test deleteGraphBlobentry!(fgclient, :gkey1) == 1
    @test !(:gkey1 in listGraphBlobentries(fgclient))

    a_de = addGraphBlobentry!(fgclient, de1)
    @test a_de.label == :gkey1

    g_entries = getGraphBlobentries(fgclient; labelFilter = startswith("gk"))
    @test length(g_entries) >= 1
    
    g_entries = getGraphBlobentries(fgclient; labelFilter = startswith("-"))
    @test isempty(g_entries)

     @test_throws DFG.LabelExistsError addGraphBlobentry!(fgclient, de1)
     @test_throws DFG.LabelExistsError addGraphBlobentries!(fgclient, [de1])

    @test_throws DFG.LabelExistsError addGraphBlobentry!(fgclient, de1)
end

@testset "Agent Blobentries" begin
    de1 = Blobentry(; blobid = uuid4(), label = :akey1, blobstore = :test)

    a_de = addAgentBlobentries!(fgclient, [de1])[1]
    g_de = getAgentBlobentry(fgclient, :akey1)
    @test a_de == g_de

    @test a_de.label == :akey1
    @test :akey1 in listAgentBlobentries(fgclient)
    @test a_de.label in map(e -> e.label, getAgentBlobentries(fgclient))
    @test deleteAgentBlobentry!(fgclient, :akey1) == 1
    @test !(:akey1 in listAgentBlobentries(fgclient))

    a_de = addAgentBlobentry!(fgclient, de1)
    @test a_de.label == :akey1

    @test_throws DFG.LabelExistsError addAgentBlobentry!(fgclient, de1)

end

@testset "Model Blobentries" begin
    model = NvaSDK.addModel!(client, NvaSDK.Model(Symbol(:TestModel, "_", randstring(4))))
    @test NvaSDK.getModel(client, model.label) == model
    @test length(NvaSDK.getModels(client)) >= 1
    de1 = Blobentry(; blobid = uuid4(), label = :mkey1, blobstore = :test)

    a_de = DFG.addModelBlobentries!(client, model, [de1])[1]
    g_de = DFG.getModelBlobentry(client, model.label, :mkey1)
    @test a_de == g_de

    @test a_de.label == :mkey1
    @test :mkey1 in DFG.listModelBlobentries(client, model.label)
    @test a_de.label in map(e -> e.label, DFG.getModelBlobentries(client, model))
    @test DFG.deleteModelBlobentry!(client, model, :mkey1) == 1
    @test !(:mkey1 in DFG.listModelBlobentries(client, model.label))

    a_de = DFG.addModelBlobentry!(client, model, de1)
    @test a_de.label == :mkey1

    @test_throws DFG.LabelExistsError DFG.addModelBlobentry!(client, model, de1)
    @test DFG.deleteModelBlobentry!(client, model, :mkey1) == 1
    #FIXME delete model
end

@testset "Variable bloblets" begin
    bloblet = DFG.Bloblet(:varbloblet, "test_value")
    addVariableBloblet!(fgclient, :a, bloblet)
    bloblets = getVariableBloblets(fgclient, :a)
    @test any(b -> b.label == :varbloblet && b.val == "test_value", bloblets)
end

@testset "Factor bloblets" begin
    bloblet = DFG.Bloblet(:facbloblet, "factor_data")
    addFactorBloblet!(fgclient, factor_labels[:rel], bloblet)
    bloblets = getFactorBloblets(fgclient, factor_labels[:rel])
    @test any(b -> b.label == :facbloblet && b.val == "factor_data", bloblets)
end
