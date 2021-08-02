using DistributedFactorGraphs, IncrementalInference, RoME
using NavAbilitySDK
using Test

include("setup.jl")
cfg, dfg = setup()

# Listing tests
@testset "Listing tests" begin
  @test ls(cfg) == ls(dfg)
  @test lsf(cfg) == lsf(dfg)
  @test listFactors(cfg, r"x0.*") == listFactors(dfg, r"x0.*")
  @test listVariables(cfg, r"x.*"; solvable=1) == listVariables(dfg, r"x.*"; solvable=1)
end

@testset "Get equivalence tests" begin
  for v in ls(cfg)
    @test getVariable(cfg, v) == getVariable(dfg, v)
  for f in lsf(cfg)
    @test getFactor(cfg, f) == getFactor(dfg, f)
end



