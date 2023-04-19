using Revise
using NavAbilitySDK

# using NavAbilityCaesarExtensions
# using IncrementalInference
# using RoME
# using DistributedFactorGraphs

# memFg = initfg()
# v = IncrementalInference.addVariable!(memFg, :x0, Pose2)
# v = IncrementalInference.addVariable!(memFg, :x1, Pose2)

client = NavAbilityHttpsClient("http://localhost:4000")
context = Client("guest@navability.io", "TestAdd", "TestAdd")

NavAbilitySDK.ls(client, context) |> fetch

# Making variables
using DistributedFactorGraphs
using IncrementalInference
using JSON3
using RoME

f = NavAbilitySDK.Factor(
    "x7f_47d3",
    "0",
    "PriorPoint3",
    ["x7"],
    NavAbilitySDK.FactorData(
        false,
        false,
        String[],
        NavAbilitySDK.PriorPoint3(
            NavAbilitySDK.FullNormal(
                [-1.3226718956785009, 1.5662947772110414e-7, -1.3717647120992105e-7],
                [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0],
                "IncrementalInference.PackedFullNormal",
            ),
        ),
        Float64[],
        Int64[],
        0.0,
        0,
        3.0,
    ),
    1,
    ["GPS_PRIOR", "FACTOR"],
    "2023-02-28T16:49:48.772Z",
    "0.18.10",
)

dfg = initfg()
v1 = addVariable!(dfg, :a, Position{1}; tags = [:POSE], solvable = 0)
v2 = addVariable!(dfg, :b, ContinuousScalar; tags = [:LANDMARK], solvable = 1)
f1 = addFactor!(
    dfg,
    [:a; :b],
    LinearRelative(IncrementalInference.Normal(50.0, 2.0));
    solvable = 0,
)

packedV1 = JSON3.read(JSON3.write(packVariable(v1)), Dict{String, Any})
packedF1 = JSON3.read(JSON3.write(packFactor(dfg, f1)), Dict{String, Any})

NavAbilitySDK.addVariablePacked(client, context, packedV1) |> fetch
NavAbilitySDK.addFactorPacked(client, context, packedF1) |> fetch

# Add the variable

# Add a new one
packedVariable = packVariable(memFg, v)
eventId = addPackedVariable(client, context, packedVariable) |> fetch
NavAbilitySDK.getStatusLatest(client, eventId) |> fetch

# Update the existing one

v = NavAbilitySDK.getVariable(client, context, "x1") |> fetch
push!(v["tags"], "TEST")

eventId = updatePackedVariable(client, context, v) |> fetch
NavAbilitySDK.getStatusLatest(client, eventId) |> fetch
