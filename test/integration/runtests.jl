using NavAbilitySDK
using DistributedFactorGraphs
using Test
using JSON
using LinearAlgebra
using Random
using UUIDs
using Dates

include("setup.jl")

@testset "NavAbilitySDK Integration Tests" begin
    @testset "Agent & Graph" begin
        include("test_agent_graph.jl")
    end
    @testset "Variables" begin
        include("test_variable.jl")
    end
    @testset "Factors" begin
        include("test_factor.jl")
    end
    @testset "Graph Queries" begin
        include("test_graph_queries.jl")
    end
    @testset "States" begin
        include("test_state.jl")
    end
    @testset "BlobEntries" begin
        include("test_blobentry.jl")
    end
    @testset "BlobStore" begin
        include("test_blobstore.jl")
    end
    @testset "Standard API" begin
        include("test_standard_api.jl")
    end

    # Cleanup: delete the test graph and agent
    @testset "Cleanup" begin
        include("test_cleanup.jl")
    end
end
