
function addPackedFactor(navAbilityClient::NavAbilityClient, client::Client, factor)::String
    response = navAbilityClient.mutate(MutationOptions(
        "addFactor",
        MUTATION_ADDFACTOR,
        Dict(
            "factor" => Dict(
                "client" => client,
                "packedData" => json(factor)
            )
        )
    ))
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(rootData["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    addFactor = get(data,"addFactor","Error")
    return addFactor
end

function addFactor(navAbilityClient::NavAbilityClient, client::Client, factor::Factor)
    return @async addPackedFactor(navAbilityClient, client, factor)
end

function _getFactorEvent(navAbilityClient::NavAbilityClient, client::Client, label::String)::Dict{String,Any}
    response = navAbilityClient.query(QueryOptions(
        "sdk_get_factor",
        """
            $GQL_FRAGMENT_FACTORS
            $GQL_GETFACTOR
        """,
        Dict(
            "label" => label,
            "userId" => client.userId,
            "robotId" => client.robotId,
            "sessionId" => client.sessionId
        )
    )) |> fetch
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(rootData["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return Dict() end
    user = get(data,"users",[])
    if size(user)[1] < 1 return Dict() end
    robots = get(user[1],"robots",[])
    if size(robots)[1] < 1 return Dict() end
    sessions = get(robots[1],"sessions",[])
    if size(sessions)[1] < 1 return Dict() end
    factors = get(sessions[1],"factors",[])
    if size(factors)[1] < 1 return Dict() end
    return factors[1]
end

getFactor(navAbilityClient::NavAbilityClient, client::Client, label::String) = @async _getFactorEvent(navAbilityClient, client, label)

function getFactorsEvent(navAbilityClient::NavAbilityClient, client::Client; detail::QueryDetail = SKELETON)::Vector{Dict{String,Any}}
    response = navAbilityClient.query(QueryOptions(
        "sdk_get_factors",
        """
            $GQL_FRAGMENT_FACTORS
            $GQL_GETFACTORS
        """,
        Dict(
            "userId" => client.userId,
            "robotId" => client.robotId,
            "sessionId" => client.sessionId,
            "fields_summary" => detail === SUMMARY || detail === FULL,
            "fields_full" => detail === FULL,
        )
    )) |> fetch
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(rootData["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return [] end
    user = get(data,"users",[])
    if size(user)[1] < 1 return [] end
    robots = get(user[1],"robots",[])
    if size(robots)[1] < 1 return [] end
    sessions = get(robots[1],"sessions",[])
    if size(sessions)[1] < 1 return [] end
    return get(sessions[1],"factors",[])
end

getFactors( navAbilityClient::NavAbilityClient, client::Client; detail::QueryDetail = SKELETON) = @async getFactorsEvent(navAbilityClient, client; detail )

function listFactors(navAbilityClient::NavAbilityClient, client::Client)
    @async begin
        factors = getFactors(navAbilityClient,client) |> fetch
        map(v -> v["label"], factors)
    end
end

function lsf(navAbilityClient::NavAbilityClient, client::Client)
    return listFactors(navAbilityClient,client)
end