
function addFactorPackedEvent(navAbilityClient::NavAbilityClient, client::Client, factor::Dict; options=Dict{String, Any}())::String
    data = Dict(
        "factorPackedInput" => Dict(
            "session" => Dict(
                "key" => client
            ),
            "packedData" => base64encode(json(factor))
        ),
        "options" => options
    )
    response = navAbilityClient.mutate(MutationOptions(
        "sdk_add_factor_packed",
        GQL_ADD_FACTOR_PACKED,
        data
    )) |> fetch

    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        @error response
        throw("Error: $(rootData["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    return data["addFactorPacked"]["context"]["eventId"]
end

function addFactorPacked(navAbilityClient::NavAbilityClient, client::Client, factor::Dict; options::Dict=Dict{String,Any}("force" => false))
    return @async addFactorPackedEvent(navAbilityClient, client, factor; options)
end

function addFactor(navAbilityClient::NavAbilityClient, client::Client, factor::Variable)
    @warn "This function signature will change during 0.6, please use addFactorPacked."
    return @async addVariablePackedEvent(navAbilityClient, client, factor; options)
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

"""
    $(SIGNATURES)
Get a Factor from a graph context using its label.

Return: Task containing the Factor.
"""
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

"""
    $(SIGNATURES)
Get a list of the Factors as labels in the graph.
"""
function listFactors(navAbilityClient::NavAbilityClient, client::Client)
    @async begin
        factors = getFactors(navAbilityClient,client) |> fetch
        map(v -> v["label"], factors)
    end
end

function lsf(navAbilityClient::NavAbilityClient, client::Client)
    return listFactors(navAbilityClient,client)
end

function FactorKey(context::Client, label::String)
    Dict{String,String}(
        "userLabel" => context.userId,
        "robotLabel" => context.robotId,
        "sessionLabel" => context.sessionId,
        "factorLabel" => label,
    )
end

function deleteFactor(client::NavAbilityClient, context::Client, label::String)
 
    deleteFactorInput = Dict(
        "id"=>Dict("key"=>FactorKey(context, label))
    )
    mo = MutationOptions(
        "sdk_delete_factor",
        GQL_DELETEFACTOR,
        Dict(
            "factor" => deleteFactorInput
        )
    )
    task = @async begin
        response = fetch(client.mutate(mo))
        rootData = JSON.parse(response.Data)
        if haskey(rootData, "errors")
            throw("Error: $(rootData["errors"])")
        end
        rootData["data"]["deleteFactor"]["context"]["eventId"]
    end

    return task
end
