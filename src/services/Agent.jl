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
    variables = (agentId=agentId,)

    T = Vector{AgentRemote}

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
mutation createAgents($input: [AgentCreateInput!]!) {
  createAgents(input: $input) {
    agents {
        label
        createdTimestamp
        namespace
    }
  }
}
"""

function addAgent!(client::NavAbilityClient, label::Symbol, agent=nothing; agentKwargs...)
    input = [
        AgentCreateInput(;
            id = getId(client.id, label),
            label,
            org = createConnect(client.id),
            getCommonProperties(AgentCreateInput, agent)...,
            getCommonProperties(AgentCreateInput, agentKwargs)...,
        )
    ]

    variables = (input=input,)

    # AgentRemoteResponse
    T = @NamedTuple{agents::Vector{AgentRemote}}

    response =
        GQL.execute(client.client, GQL_ADD_AGENTS, T; variables, throw_on_execution_error = true)

    return handleMutate(response, "createAgents", :agents)[1]
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
    variables = (id=client.id,)

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