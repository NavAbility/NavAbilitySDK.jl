QUERY_GET_AGENT = """
query QUERY_GET_AGENT(\$agentId: ID!) {
  agents (where: {id: \$agentId}) {
    id
    label
    createdTimestamp
    namespace
  }
}
"""

function getAgent(client::NavAbilityClient, label::Symbol)
    agentId = getId(client.id, label)
    variables = (agentId = agentId,)

    T = Vector{NvaNode{Agent}}

    response = GQL.execute(
        client.client,
        QUERY_GET_AGENT,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return handleQuery(response, "agents", label)
end

GQL_ADD_AGENTS = GQL.gql"""
mutation addAgents($input: [AgentCreateInput!]!) {
  addAgents(input: $input) {
    agents {
        label
        createdTimestamp
        namespace
    }
  }
}
"""

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

    response = GQL.execute(
        client.client,
        GQL_ADD_AGENTS,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return handleMutate(response, "addAgents", :agents)[1]
end

QUERY_LIST_AGENTS = GQL.gql"""
query listAgents($id: ID!) {
  orgs(where: {id: $id}) {
    agents {
      label
    }
  }
}
"""

function listAgents(client::NavAbilityClient)
    variables = (id = client.id,)

    T = Vector{Dict{String, Vector{@NamedTuple{label::Symbol}}}}

    response = GQL.execute(
        client.client,
        QUERY_LIST_AGENTS,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return last.(handleQuery(response, "orgs", Symbol(client.id))["agents"])
end

QUERY_GET_AGENT_METADATA = GQL.gql"""
query getAgentMetadata($id: ID!) {
  agents(where: {id: $id}) {
    metadata
  }
}
"""

function DFG.getAgentMetadata(fgclient::NavAbilityDFG)
    variables = (id = getId(fgclient.agent),)
    response = GQL.execute(
        fgclient.client.client,
        QUERY_GET_AGENT_METADATA;
        variables,
        throw_on_execution_error = true,
    ) 
    b64data = handleQuery(response, "agents", fgclient.agent.label)["metadata"]
    if isnothing(b64data)
        return Dict{Symbol, DFG.SmallDataTypes}()
    else
        return JSON3.read(base64decode(b64data), Dict{Symbol, DFG.SmallDataTypes})
    end
end

#TODO update to standard pattern
function DFG.setAgentMetadata!(fgclient::NavAbilityDFG, smallData::Dict{Symbol, DFG.SmallDataTypes})
    meta = base64encode(JSON3.write(smallData))
    gql = """
    mutation {
      updateAgents(
        where: { id: "$(getId(fgclient.agent))" }
        update: { metadata: "$(meta)" }
      ) {
        agents {
          metadata
        }
      }
    }
    """
    response = GQL.execute(fgclient.client.client, gql; throw_on_execution_error = true)
    return JSON3.read(
        base64decode(response.data["updateAgents"]["agents"][1]["metadata"]),
        Dict{Symbol, DFG.SmallDataTypes},
    )
end