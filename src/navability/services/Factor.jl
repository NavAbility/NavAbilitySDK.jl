using ..NavAbilitySDK
using JSON

function dump(factor::Factor)
    return json(factor)
end

function addFactor(navAbilityClient::NavAbilityClient, client::Client, factor::Factor)
    navAbilityClient.mutate(MutationOptions(
        "addFactor",
        MUTATION_ADDFACTOR,
        Dict(
            "factor" => Dict(
                "client" => client,
                "packedData" => dump(factor)
            )
        )
    ))
end

function getFactor(navAbilityClient::NavAbilityClient, client::Client, label::String)
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
    data = JSON.parse(response.Data)
    if haskey(data, "errors")
        throw("Error: $(data["errors"])")
    end

    return data["data"]["FACTOR"][1]
end

function getFactorLabels(navAbilityClient::NavAbilityClient, client::Client)::Vector{String}
    response = navAbilityClient.query(QueryOptions(
        "FactorLabels",
        QUERY_FACTOR_LABELS,
        Dict(
            "userId" => client.userId,
            "robotId" => client.robotId,
            "sessionId" => client.sessionId
        )
    ))
    data = JSON.parse(response.Data)
    if haskey(data, "errors")
        throw("Error: $(data["errors"])")
    end
    sessionData = data["data"]["SESSION"]
    if size(sessionData)[1] < 1
        return []
    end

    return map(v -> v["label"], sessionData[1]["factors"])
end

function lsf(navAbilityClient::NavAbilityClient, client::Client)::Vector{String}
    getVariableLabels(navAbilityClient,client)
end