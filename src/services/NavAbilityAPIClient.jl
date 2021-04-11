include("NavAbilityMutations.jl")

# until we define the ultimate maximum contract
const PackedDFGVariableTemp = Dict
const PackedDFGFactorTemp = Dict

function NavAbilityAPIClient(; 
                host::AbstractString="https://api.$(nvaEnv).navability.io", 
                token::Union{Nothing, <:AbstractString}="") 
  client = GraphQLClient(host, auth="Bearer $token")
  return NavAbilityAPIClient(host, token, client)
end

function _gqlClient(userId::String, robotId::String, sessionId::String)
  return Dict("userId" => userId, "robotId" => robotId, "sessionId" => sessionId)
end

function _parseGqlResponse(response, responseVerb::String)
  @debug "GraphQL response: $(response)"
  !isa(response, Diana.Result) && error("NavAbility API returned an unexpected response of type '$(typeof(response))'")
  response.Info.status != 200 && error("NavAbility API returned response code $(response.Info.status)")
  data = JSON.parse(response.Data)
  haskey(data, "errors") && length(data["errors"]) > 0 && error("Got errors from NavAbility API: $(data["errors"])")
  !haskey(data, "data") && error("NavAbility API did not return data in the payload")
  !haskey(data["data"], responseVerb) && error("NavAbility API response does not contain the verb $(responseVerb)")
  return data["data"][responseVerb]
end

# TODO: If we have time make PackedDFGVariable and PackedDFGFactor in DFG.
# TODO: What does addVariable return here? (the packed JSON/Dict of DFGVariable)
# TODO: What happens if it fails? Error or exception?
function addVariable!(client::NavAbilityAPIClient, userId::String, robotId::String, sessionId::String, packedVariable::PackedDFGVariableTemp)
  vars = Dict(
    "variable" => Dict(
      "client" => _gqlClient(userId, robotId, sessionId),
      "packedData" => JSON.json(packedVariable)) 
    )
  @debug "GraphQL payload: $(vars)"
  response = client.gqlClient.Query(MUTATION_ADDVARIABLE, operationName="addVariable", vars=vars)
  return _parseGqlResponse(response, "addVariable")
end

function addFactor!(client::NavAbilityAPIClient, userId::String, robotId::String, sessionId::String, packedFactor::PackedDFGFactorTemp)
  vars = Dict(
    "factor" => Dict(
      "client" => _gqlClient(userId, robotId, sessionId),
      "packedData" => JSON.json(packedFactor)) 
    )
  @debug "GraphQL payload: $(vars)"
  response = client.gqlClient.Query(MUTATION_ADDFACTOR, operationName="addFactor", vars=vars)
  return _parseGqlResponse(response, "addFactor")
end

#