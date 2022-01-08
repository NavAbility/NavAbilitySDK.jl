using ...NavAbilitySDK

# until we define the ultimate maximum contract
const PackedDFGVariableTemp = Dict{String,Any}
const PackedDFGFactorTemp = Dict{String,Any}

function NavAbilityAPIClient(; 
                host::AbstractString="https://api.$(nvaEnv).navability.io", 
                token::Union{Nothing, <:AbstractString}="") 
  client = GraphQLClient(host, auth="Bearer $token")
  return NavAbilityAPIClient(host, token, client)
end

function _gqlClient(userId::String, robotId::String, sessionId::String, extra::Dict{String, Any}=Dict{String, Any}())
  return merge(extra, Dict("userId" => userId, "robotId" => robotId, "sessionId" => sessionId))
end

function _parseGqlResponse(response)
  @debug "GraphQL response: $(response)"
  !isa(response, Diana.Result) && error("NavAbility API returned an unexpected response of type '$(typeof(response))'")
  response.Info.status != 200 && error("NavAbility API returned response code $(response.Info.status)")
  data = JSON.parse(response.Data)
  haskey(data, "errors") && length(data["errors"]) > 0 && error("Got errors from NavAbility API: $(data["errors"])")
  !haskey(data, "data") && error("NavAbility API did not return data in the payload")
  return data["data"]
end

function _parseGqlResponseExpectVerb(response, responseVerb::String)
  data = _parseGqlResponse(response)
  !haskey(data, responseVerb) && error("NavAbility API response does not contain the verb $(responseVerb)")
  return data[responseVerb]
end

# TODO: If we have time make PackedDFGVariable and PackedDFGFactor in DFG.
# Returns the task ID.
function addVariable!(client::NavAbilityAPIClient, userId::String, robotId::String, sessionId::String, packedVariable::PackedDFGVariableTemp)
  vars = Dict(
    "variable" => Dict(
      "client" => _gqlClient(userId, robotId, sessionId),
      "packedData" => JSON.json(packedVariable)) 
    )
  @debug "GraphQL payload: $(vars)"
  response = client.gqlClient.Query(MUTATION_ADDVARIABLE, operationName="addVariable", vars=vars)
  return _parseGqlResponseExpectVerb(response, "addVariable")
end

function addFactor!(client::NavAbilityAPIClient, userId::String, robotId::String, sessionId::String, packedFactor::PackedDFGFactorTemp)
  vars = Dict(
    "factor" => Dict(
      "client" => _gqlClient(userId, robotId, sessionId),
      "packedData" => JSON.json(packedFactor)) 
    )
  @debug "GraphQL payload: $(vars)"
  response = client.gqlClient.Query(MUTATION_ADDFACTOR, operationName="addFactor", vars=vars)
  return _parseGqlResponseExpectVerb(response, "addFactor")
end

function addSessionData!(client::NavAbilityAPIClient, gqlClient::Dict, packedVariables::Vector{PackedDFGFactorTemp}, packedFactors::Vector{PackedDFGVariableTemp})
  vars = Dict(
    "sessionData" => Dict(
      "client" => gqlClient,
      "packedVariables" => [JSON.json(v) for v in packedVariables],
      "packedFactors" => [JSON.json(f) for f in packedFactors])
    )
  @debug "GraphQL payload: $(vars)"
  response = client.gqlClient.Query(MUTATION_ADDSESSIONDATA, operationName="addSessionData", vars=vars)
  return _parseGqlResponseExpectVerb(response, "addSessionData")
end

"""
  @(SIGNATURES)
Request that the solver re-solve a session.
"""
function solveSession!(client::NavAbilityAPIClient, userId::String, robotId::String, sessionId::String)
  vars = Dict("client" => _gqlClient(userId, robotId, sessionId))
  @debug "GraphQL payload: $(vars)"
  response = client.gqlClient.Query(MUTATION_SOLVESESSION, operationName="solveSession", vars=vars)
  return _parseGqlResponseExpectVerb(response, "solveSession")
end

"""
  @(SIGNATURES)
Request that the solver perform a federated solve.
"""
function solveFederated!(client::NavAbilityAPIClient, solveScope::ScopeInput)
  vars = Dict("scope" => solveScope)
  @debug "GraphQL payload: $(vars)"
  response = client.gqlClient.Query(MUTATION_SOLVEFEDERATED, operationName="solveFederated", vars=vars)
  return _parseGqlResponseExpectVerb(response, "solveFederated")
end

"""
  @(SIGNATURES)
Execute a query and return the data if it is available.
Ref: https://grandstack.io/docs/graphql-filtering
"""
function query(client::NavAbilityAPIClient, query::String, queryName::String, vars::Dict=Dict())
  response = client.gqlClient.Query(query, operationName=queryName, vars=vars)
  return _parseGqlResponse(response)
end