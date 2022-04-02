
function _solveSession(navAbilityClient::NavAbilityClient, client::Client)::String
    response = navAbilityClient.mutate(MutationOptions(
        "solveSession",
        MUTATION_SOLVESESSION,
        Dict(
            "client" => client,
        )
    ))
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(rootData["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    solveSession = get(data,"solveSession","Error")
    return solveSession
end

solveSession(navAbilityClient::NavAbilityClient, client::Client) = @async _solveSession(navAbilityClient, client)


function _solveFederated(navAbilityClient::NavAbilityClient, scope::Scope)::String
    response = navAbilityClient.mutate(MutationOptions(
        "solveFederated",
        MUTATION_SOLVEFEDERATED,
        Dict(
            "scope" => scope,
        )
    ))
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(rootData["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    solveSession = get(data,"solveSession","Error")
    return solveSession
end

solveFederated(navAbilityClient::NavAbilityClient, scope::Scope) = @async _solveFederated(navAbilityClient, scope)

#