
function addPackedVariable(navAbilityClient::NavAbilityClient, client::Client, variable)::String
    response = navAbilityClient.mutate(MutationOptions(
        "addVariable",
        MUTATION_ADDVARIABLE,
        Dict(
            "variable" => Dict(
                "client" => client,
                "packedData" => json(variable)
            )
        )
    ))
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(rootData["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    addVariable = get(data,"addVariable","Error")
    return addVariable
end

function addVariable(navAbilityClient::NavAbilityClient, client::Client, variable::Variable)::String
    return addPackedVariable(navAbilityClient, client, variable)
end

function getVariable(navAbilityClient::NavAbilityClient, client::Client, label::String)::Dict{String,Any}
    response = navAbilityClient.query(QueryOptions(
        "sdk_get_variable",
        """
            $GQL_FRAGMENT_VARIABLES
            $GQL_GETVARIABLE
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
    variables = get(sessions[1],"variables",[])
    if size(variables)[1] < 1 return Dict() end
    return variables[1]
end

function getVariables(navAbilityClient::NavAbilityClient, client::Client; detail::QueryDetail = SKELETON)::Vector{Dict{String,Any}}
    response = navAbilityClient.query(QueryOptions(
        "sdk_get_variables",
        """
            $GQL_FRAGMENT_VARIABLES
            $GQL_GETVARIABLES
        """,
        Dict(
            "userId" => client.userId,
            "robotId" => client.robotId,
            "sessionId" => client.sessionId,
            "fields_summary" => detail === SUMMARY || detail === FULL,
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
    return get(sessions[1],"variables",[])
end

function listVariables(navAbilityClient::NavAbilityClient, client::Client)::Vector{String}
    variables = getVariables(navAbilityClient,client)
    return map(v -> v["label"], variables)
end

function ls(navAbilityClient::NavAbilityClient, client::Client)::Vector{String}
    return listVariables(navAbilityClient,client)
end