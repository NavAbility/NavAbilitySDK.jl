# Test the Standard DFG API convenience methods (type-based addVariable!/addFactor!)

@testset "Standard API: addVariable! with StateType and addFactor! with observation" begin
    std_graph = Symbol("StdAPI_", randstring(4))

    std_fgclient = NavAbilityDFG(
        AUTH_TOKEN,
        std_graph,
        TEST_AGENT_LABEL;
        apiUrl = API_URL,
        addGraphIfAbsent = true,
    )
    @test std_fgclient.fg.label == std_graph
    @test std_fgclient.agent.label == TEST_AGENT_LABEL

    v1 = addVariable!(std_fgclient, :x0, TestPosition1)
    @test v1.label == :x0

    v2 = addVariable!(std_fgclient, :x1, TestPosition2)
    @test v2.label == :x1

    @test issetequal(listVariables(std_fgclient), [:x0, :x1])

    f0 = addFactor!(std_fgclient, [:x0], TestPrior1())
    @test startswith(string(f0.label), "x0_f")

    f1 = addFactor!(std_fgclient, [:x0, :x1], TestRelative1())
    @test startswith(string(f1.label), "x0x1_f")

    fac_list = listFactors(std_fgclient)
    @test f0.label in fac_list
    @test f1.label in fac_list
    @test length(listNeighbors(std_fgclient, :x0)) == 2

    deleteVariables!(std_fgclient, listVariables(std_fgclient))
    deleteGraph!(std_fgclient)
end
