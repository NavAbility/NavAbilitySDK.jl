using DistributedFactorGraphs, IncrementalInference, RoME
using NavAbilitySDK
using Test

include("test/setup.jl")
cfg, dfg = setup()

# Need to wait a bit here for this to finish
# TODO: Monitor queue to check that it finished.

# Listing and existence tests
@testset "Listing tests" begin
  @test setdiff(ls(cfg), ls(dfg)) == []
  @test setdiff(lsf(cfg), lsf(dfg)) == []
  @test setdiff(listFactors(cfg, r"x0.*"), listFactors(dfg, r"x0.*")) == []
  @test setdiff(listVariables(cfg, r"x.*"; solvable=1), listVariables(dfg, r"x.*"; solvable=1)) == []
  @test all([exists(cfg, v) for v in ls(cfg)])
  @test all([exists(cfg, f) for f in lsf(cfg)])
  @test !any([exists(cfg, f) for f in [:whut, :cheese, :whine]])
end

import Base: ~
function ~(a::DFGVariable, b::DFGVariable)
  for f in [:label, :timestamp, :nstime, :tags]
    getfield(a, f) != getfield(b, f) && print("$f failed")==nothing && return false
  end
  # These change as we solve graphs.
  # :graphinit is added as this is solved.
  # keys(a.solverDataDict) != keys(b.solverDataDict) && print("solverDataDict failed")==nothing && return false
  # TODO: Why does this change?
  # These are refints so can't compare using getfield
  # a.solvable != b.solvable && print("Solvable failed")==nothing && return false
  return true
end
function ~(a::DFGFactor, b::DFGFactor)
  for f in [:label, :timestamp, :nstime, :tags, :_variableOrderSymbols]
    getfield(a, f) != getfield(b, f) && print("$f failed")==nothing && return false
  end
  # TODO: Why does this change?
  # These are refints so can't compare using getfield
  # a.solvable != b.solvable && print("Solvable failed")==nothing && return false
  return true
end

@testset "Get equivalence tests" begin
  for v in ls(cfg)
    @info "Testing variable $v"
    @test getVariable(cfg, v) ~ getVariable(dfg, v)
  end
  for f in lsf(cfg)
    @info "Testing factor $f"
    @test getFactor(cfg, f) ~ getFactor(dfg, f)
  end

  @test getVariables(cfg) == [getVariable(cfg, l) for l in ls(cfg)]
  @test getFactors(cfg) == [getFactor(cfg, l) for l in lsf(cfg)]
end
