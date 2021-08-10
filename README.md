# NavAbilitySDK.jl
The NavAbility SDK for Julia.

# Installation

This package is not currently registered. To install run the following:

```Pkg.add(url="https://github.com/NavAbility/NavAbilitySDK.jl.git")```

Or:

```Pkg.develop(path="/development/NavAbilitySDK.jl")```

# Using the SDK

## A Note About Supported Functionality

The CloudDFG driver is an implementation of a [DistributedFactorGraphs.jl](https://github.com/JuliaRobotics/DistributedFactorGraphs.jl) driver and supports all the functionality. However, because of the asynchronous nature of the calls, the majority of add* calls (e.g. `addVariable!` `addFactor!`) return task ID's, which need to be polled if synchronous operation is required.

The intended nature of this driver is to allow users to import local graphs into the cloud for rapid asynchronous solving and querying, so priority is given to functions like `copyGraph!` and `ls`. Please reach out if you are looking for specific functionality that does not exist yet.

Lastly, specialized functions are also being added to allow large graphs to be efficiently imported. More to follow on this.

## Connecting

Establishing a connection simply requires that you generate a client, which will direct your browser to log you into NavAbility:

```julia
cfg = CloudDFG(solverParams=SolverParams(graphinit=false))
```

If you already have a token and want to do a non-interactive login, you can pass the token directly in:

```julia
cfg = CloudDFG(token=token, solverParams=SolverParams(graphinit=false))
```

> Note: `graphinit=false` is required in the solver parameters to stop IncrementalInference from attempting to initialize the nodes locally. They are initialized and solved automatically in the cloud.

## Importing NavAbilitySDK.jl

NavAbilitySDK is intended to be used in conjunction with `DistributedFactorGraphs.jl`, `IncrementalInference.jl`, and possibly `RoME.jl`, so the following packages should be imported:

```julia
using DistributedFactorGraphs, IncrementalInference, RoME
using NavAbilitySDK
```

## Building Graphs

Graphs can be build directly using IncrementalInference.jl's `addVariable!` and `addFactor!`:

```julia
# Add a factor
taskId = addVariable!(cfg, :x0, Pose2)
# Wait for it to exist
while !(:x0 in ls(cfg)) sleep(1); end
# Add a prior
taskId = addFactor!(cfg, [:x0], PriorPose2( MvNormal([10; 10; pi/6.0], Matrix(Diagonal([0.1;0.1;0.05].^2))) ) ) 
```

The recommended approach, however, is to instantiate a local graph and then upload the local data using `copyData!`:

```julia
hex = generateCanonicalFG_Hexagonal()
copyGraph!(cfg, hex, ls(hex), lsf(hex))
```

Lastly, a more surgical method is to simply upload the local elements directly from a graph whenever is suitable:

```julia
# Create a local graph
lfg = initfg() # LightDFG
v0 = addVariable!(lfg, :x0, Pose2)
v1 = addVariable!(lfg, :x1, Pose2)
## Prior factor
x0f1 = addFactor!(lfg, [:x0], PriorPose2( MvNormal([10; 10; pi/6.0], Matrix(Diagonal([0.1;0.1;0.05].^2))) ) ) 
## Pose2Pose2 factors
pp = Pose2Pose2(MvNormal([10.0;0;pi/3], Matrix(Diagonal([0.1;0.1;0.1].^2))))
x0x1f1 = addFactor!(lfg, [:x0; :x1], pp)

# Upload these nodes to a CloudDFG instance `cfg`
result = addVariable!(cfg, v0)
result = addVariable!(cfg, v1)
result = addFactor!(cfg, x0f1)
result = addFactor!(cfg, x0x1f1)
```

> Note: At the moment the RoME.jl graph generators cannot be used directly (e.g. ```hex = generateCanonicalFG_Hexagonal(;fg=CloudDFG(solverParams=SolverParams()))```) because they expect synchronous behavior. We'll look at supporting these in the future, however locally building graphs and pushing them in bulk into the cloud is more efficient so supporting this is deprioritized for the moment.

## Checking for Task Completion

Until we implement the event and subscription API, you will need to poll data to confirm that it's been imported. Here are a few simple patterns to do this.

To check the data copy from `dfg` to `cfg` has completed:

```julia
begin
  while !(setdiff(ls(dfg), ls(cfg)) == []) 
    @info "Waiting for variables: $(setdiff(ls(dfg), ls(cfg)))"
    sleep(1)
  end
  while !(setdiff(lsf(dfg), lsf(cfg)) == []) 
    @info "Waiting for factors: $(setdiff(lsf(dfg), lsf(cfg)))"
    sleep(1)
  end
end
```

To check whether a graph has solved at least once on the `:default` key:

```julia
begin
  while !all([haskey(getVariable(cfg, v).ppeDict, :default) for v in ls(cfg)]) 
    sleep(1); 
    @info "Waiting for it to solve"; 
  end
end
```

## Querying Data

Data can be queried as though the data is local using `getVariable`/`getVariables` and `getFactor`/`getFactors`:

```julia
x0 = getVariable(cfg, :x0)
x0f1 = getVariable(cfg, :x0f1)
```

The standard `ls` and `lsf` functions (with optional regular expressions) are supported to allow for searching the graph:

```julia
variableIds = ls(cfg)
factorIds = lsf(cfg)
poseIds = listVariables(cfg, r"x\d")
poseFactorIds = listFactors(cfg, r"x0.*")
```

# Feedback or Requests

Please feel free to create an issue if you would like specific functionality or have any questions. Alternatively you can reach out directly via email at `info@navability.io`.

## Contracts Schema

- Variable Contract: https://github.com/JuliaRobotics/DistributedFactorGraphs.jl/blob/28eec11a15ffc069a2b3f0c9481938b9de3b2eb8/src/services/Serialization.jl#L112-L127
- Factor Contract: https://github.com/JuliaRobotics/DistributedFactorGraphs.jl/blob/28eec11a15ffc069a2b3f0c9481938b9de3b2eb8/src/services/Serialization.jl#L248-L274
