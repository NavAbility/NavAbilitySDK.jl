
function DFG.getAgent(client::NavAbilityClient, label::Symbol)
    agentId = getId(client, label)
    variables = (agentId = agentId,)

    T = Vector{NvaNode{Agent}}

    response = executeGql(client, GQL_OPS[:getAgent], variables, T)

    return handleQuery(response, :agents, label)
end

function addAgent!(client::NavAbilityClient, agent::DFG.Agent)
    @assert DFG.isValidLabel(getLabel(agent)) "Agent label ($(getLabel(agent))) is not a valid label"
    input = [
        AgentCreateInput(;
            id = getId(client.id, getLabel(agent)),
            org = createConnect(client.id),
            getCommonProperties(AgentCreateInput, agent)...,
        ),
    ]

    variables = (input = input,)

    # AgentRemoteResponse
    T = @NamedTuple{agents::Vector{NvaNode{Agent}}}

    response = executeGql(client, GQL_OPS[:addAgents], variables, T)

    return handleMutate(response, :addAgents, :agents)[1]
end

function deleteAgent!(client::NavAbilityClient, label::Symbol)
    response = executeGql(client, GQL_OPS[:deleteAgent], (id = getId(client, label),))

    return response
end

function listAgents(client::NavAbilityClient)
    variables = (id = client.id,)

    T = Vector{Dict{Symbol, Vector{@NamedTuple{label::Symbol}}}}

    response = executeGql(client, GQL_OPS[:listAgents], variables, T)

    return last.(handleQuery(response, :orgs, Symbol(client.id))[:agents])
end

function DFG.getAgentBloblets(client::NavAbilityClient, label::Symbol)
    variables = (id = getId(client, label),)

    T = Vector{@NamedTuple{bloblets::Vector{DFG.Bloblet}}}
    response = executeGql(client, GQL_OPS[:getAgentBloblets], variables, T)

    return handleQuery(response, :agents, label).bloblets
    
end

#TODO test me
function DFG.getAgentBloblets(fg::NavAbilityDFG)
    return getAgentBloblets(fg.client, getLabel(fg.agent))
end

function DFG.addAgentBloblet!(
    client::NavAbilityClient,
    label::Symbol,
    bloblet::DFG.Bloblet
)
    response = executeGql(
        client,
        GQL_OPS[:addAgentBloblet],
        (
            id = getId(client, label), 
            label = bloblet.label,
            val = bloblet.val
        ),
    )
    #TODO handle response
    return bloblet
end

#TODO testme
function DFG.addAgentBloblet!(fg::NavAbilityDFG, bloblet::DFG.Bloblet)
    return addAgentBloblet!(fg.client, getLabel(fg.agent), bloblet)
end
