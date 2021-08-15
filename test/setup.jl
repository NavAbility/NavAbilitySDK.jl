"""
Create a standard graph via lightgraph for testing.
"""
function setup() 
  @info "Setting up graph..."
  # create temp in memory graph that we will tee up to server via cfg
  lfg = initfg() # LightDFG

  hex = generateCanonicalFG_Hexagonal()
  # TODO: https://github.com/NavAbility/NavAbilitySDK.jl/issues/9
  # addData!(FileDataEntry, lfg, :x4, :data, "/tmp", UInt8[0,0,0,0])

  @info "Logging in to get a token...."
  cfg = CloudDFG(guestMode=true, solverParams=SolverParams())
  @info cfg
  # TODO: Test with NoSolverParams, we do not need SolverParams with CFG.
  @info "Creating graph for: "
  @info "Session: $(cfg.sessionId)"

  # Copy the generated graph
  copyGraph!(cfg, hex, ls(hex), lsf(hex))
  
  @info "Waiting a few seconds so it's all imported"

  return cfg, hex
end