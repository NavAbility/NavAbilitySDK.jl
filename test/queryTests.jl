# Ensure any graphQL client can leverage SDK via queries
using NavAbilityMutations
using Test

# Sample graphQL client library
using Diana

# Setup environment
hostname = if haskey(ENV, "HOSTNAME") ENV["HOSTNAME"] else "localhost" end
token = if haskey(ENV, "TOKEN") ENV["TOKEN"] else "" end

# Connect to NavAbility
gqlClient = GraphQLClient(hostname, auth="Bearer $token")

# Run operations against NavAbility
result = gqlClient.Query(NavAbilityMutations.MUTATION_ADDVARIABLE,operationName="AddVariable",vars=Dict(
            "variable" => "TODO: Generate variable"
        ))

# Assert success
@test result !== nothing