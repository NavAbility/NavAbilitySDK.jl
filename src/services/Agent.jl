
function DFG.getAgent(client::NavAbilityClient, label::Symbol)
    agentId = getId(client.id, label)
    variables = (agentId = agentId,)

    T = Vector{NvaNode{Agent}}

    response = executeGql(client, QUERY_GET_AGENT, variables, T)

    return handleQuery(response, "agents", label)
end

function addAgent!(client::NavAbilityClient, label::Symbol, agent = nothing; agentKwargs...)
    @assert isValidLabel(label) "Agent label ($agentLabel) is not a valid label"
    input = [
        AgentCreateInput(;
            id = getId(client.id, label),
            label,
            org = createConnect(client.id),
            getCommonProperties(AgentCreateInput, agent)...,
            getCommonProperties(AgentCreateInput, agentKwargs)...,
        ),
    ]

    variables = (input = input,)

    # AgentRemoteResponse
    T = @NamedTuple{agents::Vector{NvaNode{Agent}}}

    response = executeGql(client, GQL_ADD_AGENTS, variables, T)

    return handleMutate(response, "addAgents", :agents)[1]
end

function deleteAgent!(client::NavAbilityClient, label::Symbol)
    response = executeGql(client, GQL_DELETE_AGENT, (id = getId(client, label),))

    return response.data
end

function listAgents(client::NavAbilityClient)
    variables = (id = client.id,)

    T = Vector{Dict{String, Vector{@NamedTuple{label::Symbol}}}}

    response = executeGql(client, QUERY_LIST_AGENTS, variables, T)

    return last.(handleQuery(response, "orgs", Symbol(client.id))["agents"])
end

function DFG.getAgentMetadata(client::NavAbilityClient, label::Symbol)
    variables = (id = getId(client, label),)

    response = executeGql(client, QUERY_GET_AGENT_METADATA, variables, Any)

    b64data = handleQuery(response, "agents", label)["metadata"]
    if isnothing(b64data)
        return Dict{Symbol, DFG.SmallDataTypes}()
    else
        return JSON3.read(base64decode(b64data), Dict{Symbol, DFG.SmallDataTypes})
    end
end

function DFG.getAgentMetadata(fgclient::NavAbilityDFG)
    variables = (id = getId(fgclient.agent),)

    response = executeGql(fgclient, QUERY_GET_AGENT_METADATA, variables, Any)

    b64data = handleQuery(response, "agents", fgclient.agent.label)["metadata"]
    if isnothing(b64data)
        return Dict{Symbol, DFG.SmallDataTypes}()
    else
        return JSON3.read(base64decode(b64data), Dict{Symbol, DFG.SmallDataTypes})
    end
end

#TODO update to standard pattern
function DFG.setAgentMetadata!(
    fgclient::NavAbilityDFG,
    smallData::Dict{Symbol, DFG.SmallDataTypes},
)
    meta = base64encode(JSON3.write(smallData))

    response = executeGql(
        fgclient,
        QUERY_SET_AGENT_METADATA,
        (id = getId(fgclient.agent), meta=meta),
    )
    return JSON3.read(
        base64decode(response.data["updateAgents"]["agents"][1]["metadata"]),
        Dict{Symbol, DFG.SmallDataTypes},
    )
end
