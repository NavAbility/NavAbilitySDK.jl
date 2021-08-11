# A transport-layer client
struct NavAbilityAPIClient
    host::String
    token::Union{Nothing, String}
    gqlClient::Diana.Client  
end

# Input for the solveFederated
struct ScopeInput {
  environmentIds::Vector{String}
  userIds::Vector{String}
  robotIds::Vector{String}
  sessionIds::Vector{String}
}