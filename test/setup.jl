"""
Create a standard graph via lightgraph for testing.
"""
function setup() 
  @info "Setting up graph..."
  # create temp in memory graph that we will tee up to server via cfg
  lfg = initfg() # LightDFG

  # TODO: Move over to standard graph generators,
  # but keeping this like this for now so I have greater control
  # for testing
  v0 = addVariable!(lfg, :x0, Pose2)
  v1 = addVariable!(lfg, :x1, Pose2)
  v2 = addVariable!(lfg, :x2, Pose2)
  v3 = addVariable!(lfg, :l1, Pose2, tags=[:LANDMARK])
  v4 = addVariable!(lfg, :x4, Pose2)
  # TODO: https://github.com/NavAbility/NavAbilitySDK.jl/issues/9
  # addData!(FileDataEntry, lfg, :x4, :data, "/tmp", UInt8[0,0,0,0])

  x0f1 = addFactor!(lfg, [:x0], PriorPose2( MvNormal([10; 10; pi/6.0], Matrix(Diagonal([0.1;0.1;0.05].^2))) ) ) 
  pp = Pose2Pose2(MvNormal([10.0;0;pi/3], Matrix(Diagonal([0.1;0.1;0.1].^2))))
  x0x1f1 = addFactor!(lfg, [:x0; :x1], pp)
  x1x2f1 = addFactor!(lfg, [:x1; :x2], deepcopy(pp))
  
  @info "Logging in to get a token...."
  # token = ""
  # cfg = CloudDFG(token=token, solverParams=SolverParams())
  cfg = CloudDFG(solverParams=SolverParams())
  @info cfg
  # TODO: Test with NoSolverParams, we do not need SolverParams with CFG.
  @info "Creating graph for: "
  @info "Session: $(cfg.sessionId)"
  for vSymbol in ls(lfg)
    @info "Adding variable $vSymbol, task ID = $(addVariable!(cfg, getVariable(lfg, vSymbol)))"
  end
  for fSymbol in lsf(lfg)
    @info "Adding factor $fSymbol, task ID = $(addFactor!(cfg, getFactor(lfg, fSymbol)))"
  end
  
  @info "Setup complete!"
  return cfg, lfg
end