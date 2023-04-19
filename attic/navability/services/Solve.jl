
function solveSessionEvent(navAbilityClient::NavAbilityClient, client::Client, solveOptions::Union{SolveOptions, Nothing})::String
    payload = Dict{String, Any}(
        "client" => client,
    )
    if (!isnothing(solveOptions))
        payload["options"] = solveOptions
    end
    response = navAbilityClient.mutate(MutationOptions(
        "solveSession",
        MUTATION_SOLVESESSION,
        payload
    )) |> fetch
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(rootData["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    solveSession = get(data,"solveSession","Error")
    return solveSession
end

solveSession(navAbilityClient::NavAbilityClient, client::Client, solveOptions::Union{SolveOptions, Nothing} = nothing) = @async solveSessionEvent(navAbilityClient, client, solveOptions)


function solveFederatedEvent(navAbilityClient::NavAbilityClient, scope::Scope)::String
    response = navAbilityClient.mutate(MutationOptions(
        "solveFederated",
        MUTATION_SOLVEFEDERATED,
        Dict(
            "scope" => scope,
        )
    )) |> fetch
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(rootData["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    solveSession = get(data,"solveSession","Error")
    return solveSession
end

solveFederated(navAbilityClient::NavAbilityClient, scope::Scope) = @async solveFederatedEvent(navAbilityClient, scope)

#