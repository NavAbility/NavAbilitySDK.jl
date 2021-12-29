using ..NavAbilitySDK
using JSON

function dump(variable::Variable)
    return json(variable)
end

function addVariable(navAbilityClient::NavAbilityClient, client::Client, variable::Variable)
    navAbilityClient.mutate(MutationOptions(
        "addVariable",
        MUTATION_ADDVARIABLE,
        Dict(
            "variable" => Dict(
                "client" => client,
                "packedData" => dump(variable)
            )
        )
    ))
end

function getVariable(navAbilityClient::NavAbilityClient, client::Client, label::String)
    response = navAbilityClient.query(QueryOptions(
        "Variable",
        QUERY_VARIABLE,
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

    return data["data"]["VARIABLE"][1]
end

function getVariableLabels(navAbilityClient::NavAbilityClient, client::Client)::Vector{String}
    response = navAbilityClient.query(QueryOptions(
        "VariableLabels",
        QUERY_VARIABLE_LABELS,
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

    return map(v -> v["label"], sessionData[1]["variables"])
end

function ls(navAbilityClient::NavAbilityClient, client::Client)::Vector{String}
    getVariableLabels(navAbilityClient,client)
end