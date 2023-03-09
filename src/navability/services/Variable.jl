
function Variable(
    label::AbstractString, 
    type::Union{<:AbstractString, Symbol}, 
    tags::AbstractVector{<:AbstractString} = ["VARIABLE"], 
    timestamp::String = string(now(Dates.UTC))*"Z"; 
    kwargs...
)::Variable
    variableType = type isa Symbol ? get(_variableTypeConvert, type, Nothing) : type
    type == Nothing && error("Variable type '$(type) is not supported")

    solverDataDict = Dict("default" => _getSolverDataDict(variableType, "default"))
    result = Variable(;
        label,
        variableType,
        # TODO, should not require jsoning, see DFG#867, dropped in DFG v0.19+
        solverDataDict = json(solverDataDict),
        tags = json(tags),
        timestamp,
        kwargs...
    )
    return result
end

function addVariablePackedEvent(navAbilityClient::NavAbilityClient, client::Client, variable::Dict; options=Dict{String, Any}())::String
    data = Dict(
        "variablePackedInput" => Dict(
            "session" => Dict(
                "key" => client
            ),
            "packedData" => base64encode(json(variable))
        ),
        "options" => options
    )
    response = navAbilityClient.mutate(MutationOptions(
        "sdk_add_variable_packed",
        GQL_ADD_VARIABLE_PACKED,
        data
    )) |> fetch

    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        @error response
        throw("Error: $(rootData["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    return data["addVariablePacked"]["context"]["eventId"]
end


function addVariablePacked(navAbilityClient::NavAbilityClient, client::Client, variable::Dict; options::Dict=Dict{String,Any}("force" => false))
    return @async addVariablePackedEvent(navAbilityClient, client, variable; options)
end

function updateVariablePacked(navAbilityClient::NavAbilityClient, client::Client, variable::Dict; options::Dict=Dict{String,Any}("force" => true))
    return @async addVariablePackedEvent(navAbilityClient, client, variable; options)
end

function addVariable(navAbilityClient::NavAbilityClient, client::Client, variable::Variable)
    @warn "This function signature will change during 0.6, please use addVariablePacked."
    return @async addVariablePackedEvent(navAbilityClient, client, JSON3.read(JSON3.write(variable), Dict{string, Any}); options)
end

function updateVariable(navAbilityClient::NavAbilityClient, client::Client, variable::Variable)
    @warn "This function signature will change during 0.6, please use updateVariablePacked."
    return @async updateVariablePacked(navAbilityClient, client, json(variable))
end

function getVariableEvent(
    navAbilityClient::NavAbilityClient, 
    client::Client, 
    label::String;
    detail::QueryDetail = SKELETON
)::Dict{String,Any}
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
            "sessionId" => client.sessionId,
            # "fields_summary" => detail === SUMMARY || detail === FULL,
            # "fields_full" => detail === FULL,
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

"""
    $(SIGNATURES)
Get a Variable from a graph using its label.

Returns: Task with reponse Variable.
"""
getVariable(navAbilityClient::NavAbilityClient, client::Client, label::String; detail::QueryDetail = SKELETON) = @async getVariableEvent(navAbilityClient, client, label; detail)

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


function listVariablesEvent(
    client::NavAbilityClient, 
    context::Client
)
    response = client.query(QueryOptions(
        "sdk_list_variables",
        GQL_LISTVARIABLES,
        Dict(
            "userId" => context.userId,
            "robotId" => context.robotId,
            "sessionId" => context.sessionId,
        )
    )) |> fetch
    payload = JSON.parse(response.Data)
    try 
        # FIXME, this list can be empty, using try catch as lazy check
        (s->s["label"]).(payload["data"]["users"][1]["robots"][1]["sessions"][1]["variables"])
    catch err
        if err isa BoundsError
            String[]
        else
            throw(err)
        end
    end
end

"""
    $(SIGNATURES)
Get a list of Variable labels in the graph.

Returns: A Task with response `::Vector{String}`.
"""
function listVariables(client::NavAbilityClient, context::Client)
    @async listVariablesEvent(client, context)
    # @async begin
    #     # FIXME, upgrade to use a direct listVariables API call instead
    #     variables = getVariables(client,context) |> fetch
    #     map(v -> v["label"], variables)
    # end
end

function ls(client::NavAbilityClient, context::Client)
    return listVariables(client, context)
end

function listFactorsEvent(
    client::NavAbilityClient, 
    ::Client, 
    variableKey::Dict
)
    response = client.query(QueryOptions(
        "sdk_list_variable_neighbors",
        GQL_LIST_VARIABLE_NEIGHBORS,
        variableKey
    )) |> fetch
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        @error response
        throw("Error: $(rootData["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    # listVarNei = get(data,"users","Error")
    return (s->s["label"]).(data["users"][1]["robots"][1]["sessions"][1]["variables"][1]["factors"])
end

function listFactorsEvent(client::NavAbilityClient, context::Client, varLbl::AbstractString)
    listFactorsEvent(
        client, 
        context, 
        VariableKey(
            context.userId, 
            context.robotId, 
            context.sessionId,
            varLbl
        )
    )
end

listFactors(client::NavAbilityClient, context::Client, w...; kw...) = @async listFactorsEvent(client, context, w...; kw...)

function initVariableEvent(
        client::NavAbilityClient, 
        context::Client, 
        initVariableInput::Dict,
    )
    #
    mo = MutationOptions(
        "sdk_init_variable",
        GQL_INIT_VARIABLE,
        Dict(
            "variable" => initVariableInput
        )
    )
    response = client.mutate(mo) |> fetch
    
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(rootData["errors"])")
    end
    return rootData["data"]["initVariable"]["context"]["eventId"]
end
# Dict(
#     "userId" => context.userId,
#     "robotId" => context.robotId,
#     "sessionId" => context.sessionId,
#     "label" => label,
#     "variableType" => varType,
#     "points" => points
# )

initVariable(w...;kw...) = @async initVariableEvent(w...;kw...)

#