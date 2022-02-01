using ..NavAbilitySDK
using JSON

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

function addFactor(navAbilityClient::NavAbilityClient, client::Client, factor::Factor)::String
    return addPackedFactor(navAbilityClient, client, factor)
end

function getFactor(navAbilityClient::NavAbilityClient, client::Client, label::String)::Dict{String,Any}
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
    ))
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

function getFactors(navAbilityClient::NavAbilityClient, client::Client; detail::QueryDetail = SKELETON)::Vector{Dict{String,Any}}
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
            "fields_summary" => detail === SUMMARY,
            "fields_full" => detail === FULL,
        )
    ))
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

function listFactors(navAbilityClient::NavAbilityClient, client::Client)::Vector{String}
    factors = getFactors(navAbilityClient,client)
    return map(v -> v["label"], factors)
end

function lsf(navAbilityClient::NavAbilityClient, client::Client)::Vector{String}
    return listFactors(navAbilityClient,client)
end