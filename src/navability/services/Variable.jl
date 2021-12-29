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

    return map(v -> v["label"], data["data"]["SESSION"][1]["variables"])
end

function ls(navAbilityClient::NavAbilityClient, client::Client)::Vector{String}
    getVariableLabels(navAbilityClient,client)
end