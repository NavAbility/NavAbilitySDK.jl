using ..NavAbilitySDK
using JSON

function dump(variable::Variable)
    return json(variable)
end

function addVariable(navAbilityClient::NavAbilityClient, client::Client, variable::Variable)::String
    addPackedVariable(navAbilityClient, client, dump(variable))
end

function addPackedVariable(navAbilityClient::NavAbilityClient, client::Client, variable::String)::String
    response = navAbilityClient.mutate(MutationOptions(
        "addVariable",
        MUTATION_ADDVARIABLE,
        Dict(
            "variable" => Dict(
                "client" => client,
                "packedData" => variable
            )
        )
    ))
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(data["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    addVariable = get(data,"addVariable","Error")
    return addVariable
end

function getVariable(navAbilityClient::NavAbilityClient, client::Client, label::String)::Dict{String,Any}
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
    variables = get(sessions[1],"variables",[])
    if size(variables)[1] < 1 return Dict() end
    return variables[1]
end

function getVariables(navAbilityClient::NavAbilityClient, client::Client)::Vector{Dict{String,Any}}
    response = navAbilityClient.query(QueryOptions(
        "Variables",
        QUERY_VARIABLES,
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
    return get(sessions[1],"variables",[])
end

function ls(navAbilityClient::NavAbilityClient, client::Client)::Vector{String}
    variables = getVariables(navAbilityClient,client)
    return map(v -> v["label"], variables)
end