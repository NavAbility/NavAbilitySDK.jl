# NavAbilitySDK.jl
We can find the best name later (Not For Public Consumption ... yet)

This is a sandbox for getting the NavAbility Julia SDK to common cloud API design figured out in private, and we will all greenlight before making public, with roadmap.

# Sibling Code Here

## In cloud-system

- https://github.com/NavAbility/cloud-system/tree/master/libraries

## Previous Attempts

- https://juliarobotics.org/Caesar.jl/latest/concepts/multilang/

# Design Meeting 1

See Wiki (and edit as necessary)
- https://github.com/NavAbility/cloud-system/wiki/Defining-SDK-API-(to-use-GraphQL-in-Edge-Twin-Swarm)

# Installation

This package is not currently registered. To install run the following:

```Pkg.develop(url="https://github.com/NavAbility/NavAbilitySDK.jl.git")```

Or:

```Pkg.develop(path="/development/NavAbilitySDK.jl")```
## Testing

To run the tests, you need to set up the connection to the NavAbility services. These are configured in `test/configDevNavAbility.json`.

Then you can run `]` and `test NavAbilitySDK`.