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
  # token = ""
  # cfg = CloudDFG(token=token, solverParams=SolverParams())
  cfg = CloudDFG(guestMode=true, solverParams=SolverParams())
  @info cfg
  # TODO: Test with NoSolverParams, we do not need SolverParams with CFG.
  @info "Creating graph for: "
  @info "Session: $(cfg.sessionId)"

  # Copy the generated graph
  copyGraph!(cfg, hex, ls(hex), lsf(hex))
  
  @info "Waiting a few seconds so it's all imported"

  @time begin
    while !(setdiff(ls(hex), ls(cfg)) == []) 
      @info "Waiting for variables: $(setdiff(ls(hex), ls(cfg)))"
      sleep(1)
    end
    while !(setdiff(lsf(hex), lsf(cfg)) == []) 
      @info "Waiting for factors: $(setdiff(lsf(hex), lsf(cfg)))"
      sleep(1)
    end
  end
  @info "Setup complete!"

  return cfg, hex
end