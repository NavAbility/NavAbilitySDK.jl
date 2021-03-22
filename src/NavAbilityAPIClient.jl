using Diana

include("NavAbilityMutations.jl")

# until we define the ultimate maximum contract
const PackedDFGVariableTemp = Dict


# A transport-layer client
struct NavAbilityAPIClient
    host::String
    # At this point we should either do 3-legged Auth 
    # to get a token, but leaving that up to you, whichever
    # you think is best. Just putting a token in here for now.
    token::Union{Nothing, String}
    gqlClient::Diana.Client  
end

function NavAbilityAPIClient(;host::AbstractString="https://api.d1.navability.io", token::Union{Nothing, <:AbstractString}="") 
  @warn "Removing the token for the moment."
  client = GraphQLClient(host)
  # client = GraphQLClient(host, auth="Bearer $token")
  return NavAbilityAPIClient(host, token, client)
end


# TODO: If we have time make PackedDFGVariable and PackedDFGFactor in DFG.
# TODO: What does addVariable return here? (the packed JSON/Dict of DFGVariable)
# TODO: What happens if it fails? Error or exception?
function addVariable!(client::NavAbilityAPIClient, packedVariable::PackedDFGVariableTemp) # TODO: What the hell is a packedStr? Make it something strongly typed
  token = client.token
  @info "We're sending this now to GraphQL: "
  @info packedVariable
  @show "MUAHAHAHAHAHAHaH...ha"
  # not sure if packedObj should be Dict, String, (maybe later we can go to hard type, not now)
  @info client.gqlClient.Query(MUTATION_ADDVARIABLE,operationName="addVariable",
        vars=Dict(
            "variable" => Dict(
              "client" => Dict("userId" => "Guest", "robotId" => "Robot", "sessionId" => "Session"),
              "packedData" => JSON.json(packedVariable)) # If this is a string?
            )
        )
end

#