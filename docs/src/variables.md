# [Working with Variables](@id work_w_variables)

## Inspect an Existing Graph

Most use cases will involve retrieving information from a factor graph session already available on the server.  With auth [auth token](@ref auth_token), setup the connections to API server:
```julia
# copy the auth token from the NavAbility App
auth_token = "r3ft ... eo7_"

# also create a client connection
client = NavAbilityHttpsClient(;auth_token)

# create a client context user, robot, session
context = Client(
  # you need a unique userId:robotId, and can keep using that across all tutorials
  "guest@navability.io",
  "ExampleRobot",
  # You'll need a unique session number each time you run a new graph
  "Hexagonal",
)
```

```@docs
NavAbilityHttpsClient
Client
```

### Variables

Variables represent state variables of interest such as vehicle or landmark positions, sensor calibration parameters, and more. Variables are likely hidden values that are not directly observed, but we want to estimate them from observed data.  Let's start by listing all the variables in the session:
```julia
varLbls = fetch(listVariables(client, context))
# ["l1","x0","x1","x2","x3","x4","x5","x6"]
```

The fetch call is used to wait on the underlying asynchronous call.

```@docs
listVariables
```

## Data `BlobEntry=>Blob`

Additional data attached to variables exist in a few different ways.  The primary method for storing additional large data blobs with a variable, is to look at the `BlobEntry`s associated with a particular variable.  For example:
```julia
de = listBlobEntries(client, context, "x0") |> fetch
de .|> s->s["blobLabel"]
# e.g. ["Camera0", "user_calibration", etc.]
```

Data blobs can be fetched via, e.g. using the unique `blobId` of the first `dataEntry` on this variable:
```julia
blob = getBlob(client, context, de[1]["blobId"]; checkhash=false)
# [0x2e, 0x45, ..., 0x2b] # length 1225 bytes
```

Data blobs are provided in binary format (i.e. `::Vector{UInt8}`).  A blob can be associated via any number of `BlobEntry`s across multiple graph nodes, sessions, or robots.  `BlobEntry` also stores a hash value to ensure data consistency which must correspond to teh stored hash upon retrieval.  The check can be skipped as indicated by the option in the function call above.

See [Tutorial 5 from ICRA 2022 for a more indepth example of working with data blobs](https://app.navability.io/get-started/tutorials/icra-5-marineexample).

!!! note
    A blob is owned by a `user` and only accessible by other users if allowed via approved roles or permissions.

!!! note
    All `blobId`s are unique across the entire distributed system and are immutable.

```@docs
listBlobEntries
getBlob
```

## Numerical Solution

The main purpose of using a factor graph is not only as data index but also to deeply connect with the mapping and localization problem.  Variables in the factor graph represent the states to be estimated from the relevant measurement data.  The numerical values for each variable are computed by any number of solver operations.  The numerical results are primarily stored in a variables `solverData` field, such that either parametric or non-parametric inference results can be used:
```julia
v0 = getVariable(client, context, "x0")
```

```@docs
getVariable
```

### Understanding `solveKey`s

Since various numerical solutions may exists for the same factor graph, we introduce the idea of a `solveKey`.  Different numerical values for different `solveKey`s can exists for any number of reasons.  Using the example from above, we might find:
```julia
v0["solverData"][1]["solveKey"]
# graphinit
v0["solverData"][2]["solveKey"]
# default
v0["solverData"][3]["solveKey"]
# parametric
```

Each of these `solverData`s are unique identified via the `solveKey`.  The `graphinit` solver values are a duplicate of the numerical values for the variable before inference computation was performed.  In this example the `default` key corresponds to the nonparametric solution, and `parametric` represents a Gaussian only parametric solution.

The numerical values can be obtained from the `solverData` via:
```julia
v0["solverData"][3]["vecval"]
# [-0.001, 0.002, 0.001]
```

### Understanding `PPE`s

To better bridge the gap between non-Gaussian and Gaussian solutions, variables also store a convenience numerical solution called the parametric point estimate (`PPE`) for each of the `solveKey`s.  While various forms of `PPE`s can exists---such as mean, max, modes, etc.---a common `suggested` field exists for basic usage.  For example, the suggested parametric equivalent solution from the nonparametric solver (`default`) can be obtained by:
```julia
xyr = v0["ppes"][2]["suggested"]
# [-0.00, 0.00, 0.00]
```

!!! warning
    At time of writing these numerical values represent the solution stored in coordinates.  In the future, these values are expected to stored directly as on-manifold point representations.  The internal solver computations are already all on-manifold.  For more information, see [the on-manifold points, tangent vectors, and coordinates description presented here](https://juliarobotics.org/Caesar.jl/latest/concepts/using_manifolds/).

## SDK Supported Variables

The list of variable types currently supported by the SDK are:
- `Position1` / `ContinuousScalar`
- `Position2` / `Point2`
- `Pose2`
- `Position3` / `Point3`
- `Pose3`

!!! note
    Many more variable types are already supported by the solver, see [additional docs here](https://juliarobotics.org/Caesar.jl/latest/concepts/available_varfacs/).  Reach out to NavAbility for help or support in bringing more variable types to the SDK sooner, or for help in building more variable types that may not yet exist in either libraries.