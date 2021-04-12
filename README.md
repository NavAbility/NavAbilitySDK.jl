# NavAbilitySDK.jl
The NavAbility SDK for Julia.

# Installation

This package is not currently registered. To install run the following:

```Pkg.develop(url="https://github.com/NavAbility/NavAbilitySDK.jl.git")```

Or:

```Pkg.develop(path="/development/NavAbilitySDK.jl")```
## Testing

To run the tests, you need to set up the connection to the NavAbility services. These are configured in `test/configDevNavAbility.json`.

Then you can run `]` and `test NavAbilitySDK`.

# References 

## Contracts Schema

In the mean time:
- Variable Contract: https://github.com/JuliaRobotics/DistributedFactorGraphs.jl/blob/28eec11a15ffc069a2b3f0c9481938b9de3b2eb8/src/services/Serialization.jl#L112-L127
- Factor Contract: https://github.com/JuliaRobotics/DistributedFactorGraphs.jl/blob/28eec11a15ffc069a2b3f0c9481938b9de3b2eb8/src/services/Serialization.jl#L248-L274
