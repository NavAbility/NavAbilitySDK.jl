using ..NavAbilitySDK
using JSON

function dump(factor::Factor)
    return json(factor)
end

function addFactor(navAbilityClient::NavAbilityClient, client::Client, factor::Factor)::String
    addPackedVariable(navAbilityClient, client, dump(factor))
end

function addPackedFactor(navAbilityClient::NavAbilityClient, client::Client, factor::String)::String
    response = navAbilityClient.mutate(MutationOptions(
        "addFactor",
        MUTATION_ADDFACTOR,
        Dict(
            "factor" => Dict(
                "client" => client,
                "packedData" => factor
            )
        )
    ))
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(data["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    addFactor = get(data,"addFactor","Error")
    return addFactor
end

function getFactor(navAbilityClient::NavAbilityClient, client::Client, label::String)::Dict{String,Any}
    response = navAbilityClient.query(QueryOptions(
        "Factor",
        QUERY_FACTOR,
        Dict(
            "label" => label,
            "userId" => client.userId,
            "robotId" => client.robotId,
            "sessionId" => client.sessionId
        )
    ))
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(data["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return Dict() end
    user = get(data,"USER",[])
    if size(user)[1] < 1 return Dict() end
    robots = get(user[1],"robots",[])
    if size(robots)[1] < 1 return Dict() end
    sessions = get(robots[1],"sessions",[])
    if size(sessions)[1] < 1 return Dict() end
    factors = get(sessions[1],"factors",[])
    if size(factors)[1] < 1 return Dict() end
    return factors[1]
end

function getFactors(navAbilityClient::NavAbilityClient, client::Client)::Vector{Dict{String,Any}}
    response = navAbilityClient.query(QueryOptions(
        "Factors",
        QUERY_FACTORS,
        Dict(
            "userId" => client.userId,
            "robotId" => client.robotId,
            "sessionId" => client.sessionId
        )
    ))
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(data["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return [] end
    user = get(data,"USER",[])
    if size(user)[1] < 1 return [] end
    robots = get(user[1],"robots",[])
    if size(robots)[1] < 1 return [] end
    sessions = get(robots[1],"sessions",[])
    if size(sessions)[1] < 1 return [] end
    return get(sessions[1],"factors",[])
end

function lsf(navAbilityClient::NavAbilityClient, client::Client)::Vector{String}
    factors = getFactors(navAbilityClient,client)
    return map(v -> v["label"], factors)
end