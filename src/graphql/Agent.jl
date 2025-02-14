QUERY_GET_AGENT = GQL.gql"""
query QUERY_GET_AGENT($agentId: ID!) {
  agents (where: {id: $agentId}) {
    id
    label
    createdTimestamp
    namespace
  }
}
"""

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

GQL_DELETE_AGENT = GQL.gql"""
mutation deleteAgent($id: ID!) {
  deleteAgents(
    where: { id: $id }
    delete: {
      blobEntries: {
        where: { node: { parentConnection: {Agent: {node: {id: $id } } } } }
      }
    }
  ) {
    nodesDeleted
    relationshipsDeleted
  }
}
"""

QUERY_LIST_AGENTS = GQL.gql"""
query listAgents($id: ID!) {
  orgs(where: {id: $id}) {
    agents {
      label
    }
  }
}
"""

QUERY_GET_AGENT_METADATA = GQL.gql"""
query getAgentMetadata($id: ID!) {
  agents(where: {id: $id}) {
    metadata
  }
}
"""

QUERY_SET_AGENT_METADATA = GQL.gql"""
mutation setAgentMetadata($id: ID!, $meta: String!) {
  updateAgents(
    where: { id: $id }
    update: { metadata: $meta }
  ) {
    agents {
      metadata
    }
  }
}
"""
