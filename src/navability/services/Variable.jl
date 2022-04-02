
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
    )) |> fetch
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(rootData["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    addVariable = get(data,"addVariable","Error")
    return addVariable
end

function addVariable(navAbilityClient::NavAbilityClient, client::Client, variable::Variable)
    return @async addPackedVariable(navAbilityClient, client, variable)
end

function getVariableEvent(navAbilityClient::NavAbilityClient, client::Client, label::String)::Dict{String,Any}
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
    variables = get(sessions[1],"variables",[])
    if size(variables)[1] < 1 return Dict() end
    return variables[1]
end

getVariable(navAbilityClient::NavAbilityClient, client::Client, label::String) = @async getVariableEvent(navAbilityClient, client, label)

function getVariablesEvent(navAbilityClient::NavAbilityClient, client::Client; detail::QueryDetail = SKELETON)::Vector{Dict{String,Any}}
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
    return get(sessions[1],"variables",[])
end

getVariables(navAbilityClient::NavAbilityClient, client::Client; detail::QueryDetail = SKELETON) = @async getVariablesEvent(navAbilityClient, client; detail)

function listVariables(navAbilityClient::NavAbilityClient, client::Client)
    @async begin
        variables = getVariables(navAbilityClient,client) |> fetch
        map(v -> v["label"], variables)
    end
end

function ls(navAbilityClient::NavAbilityClient, client::Client)
    return listVariables(navAbilityClient,client)
end