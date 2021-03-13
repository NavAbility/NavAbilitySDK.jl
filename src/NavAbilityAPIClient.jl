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
    client = GraphQLClient(host, auth="Bearer $token")
    return NavAbilityAPIClient(host, token, client)
end


# TODO: If we have time make PackedDFGVariable and PackedDFGFactor in DFG.
# TODO: What does addVariable return here? (the packed JSON/Dict of DFGVariable)
# TODO: What happens if it fails? Error or exception?
function addVariable!(client::NavAbilityAPIClient, packedObj) # TODO: What the hell is a packedStr? Make it something strongly typed
  token = client.token
  @info "We're sending this now to GraphQL: "
  @info packedObj
  # not sure if packedObj should be Dict, String, (maybe later we can go to hard type, not now)
  @info client.gqlClient.Query(MUTATION_ADDFACTOR,operationName="AddVariable",vars=Dict(
            "variable" => packedObj) # If this is a string?
        )
end

# minimum requirements what is in packed::Dict is at least DFGVariableSummary+ (TODO define PackedDFGVariable)
function addVariable!(client::NavAbilityAPIClient, packedVariable::PackedDFGVariableTemp) # TODO: What the hell is a packed? Make it something strongly typed
  # this part might excessive
  packedStr = JSON.json(packedVariable)
  addVariable!(client, packedStr)
end

#