using DistributedFactorGraphs, IncrementalInference, RoME
using NavAbilitySDK
using Test

# Build a standard graph using a generator
include("setup.jl")
cfg, dfg = setup()

# Wait for the graph to be built out.
function waitForCopyToComplete(sourceFg, destinationFg)
  @time begin
    while !(setdiff(ls(sourceFg), ls(destinationFg)) == []) 
      @info "Waiting for variables: $(setdiff(ls(sourceFg), ls(destinationFg)))"
      sleep(1)
    end
    while !(setdiff(lsf(sourceFg), lsf(destinationFg)) == []) 
      @info "Waiting for factors: $(setdiff(lsf(sourceFg), lsf(destinationFg)))"
      sleep(1)
    end
  end
end

waitForCopyToComplete(dfg, cfg)

# @info "Check (and time) the solving:"
# @time begin
#   while !all([haskey(getVariable(cfg, v).ppeDict, :default) for v in ls(cfg)]) 
#     sleep(1); 
#     @info "Waiting for it to solve"; 
#   end
# end


# Listing and existence tests
@testset "Listing tests" begin
  @test setdiff(ls(cfg), ls(dfg)) == []
  @test setdiff(lsf(cfg), lsf(dfg)) == []
  @test setdiff(listVariables(cfg, r"x\d"), listVariables(dfg, r"x\d")) == []
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

@testset "Solving tests" begin
  # Request a resolve
  @test solveSession!(cfg) !== nothing

  # Create a copy of the graph 
  cfg2 = deepcopy(cfg);
  cfg2.sessionId *= "_session2"
  copyGraph!(cfg2, dfg, ls(dfg), lsf(dfg))
  waitForCopyToComplete(dfg, cfg2)

  # Request a federated solve
  scopeInput = ScopeInput([], [cfg.userId], [cfg.robotId], [cfg.sessionId, cfg2.sessionId])
  @info "We're skipping federated solving for now, until we can validate its flow"
#  @test solveFederated!(cfg, scopeInput) !== nothing
end