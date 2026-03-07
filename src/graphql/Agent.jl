QUERY_GET_AGENT = GQL.gql"""
query QUERY_GET_AGENT($agentId: UUID!) {
  agents (where: {id: {eq: $agentId}}) {
    label
    namespace
  }
}
"""

GQL_ADD_AGENTS = GQL.gql"""
mutation addAgents($input: [AgentCreateInput!]!) {
  addAgents(input: $input) {
    agents {
        label
        namespace
    }
  }
}
"""

GQL_DELETE_AGENT = GQL.gql"""
mutation deleteAgent($id: UUID!) {
  deleteAgents(
    where: { id: {eq: $id} }
    delete: {
      blobentries: {},
      bloblets: {}
    }
  ) {
    nodesDeleted
    relationshipsDeleted
  }
}
"""

QUERY_LIST_AGENTS = GQL.gql"""
query listAgents($id: UUID!) {
  orgs(where: {id: {eq: $id}}) {
    agents {
      label
    }
  }
}
"""

QUERY_GET_AGENT_BLOBLETS = GQL.gql"""
query getAgentBloblets($id: UUID) {
  agents(where: {id: {eq: $id}}) {
    bloblets {
      label
      val
    }
  }
}
"""

QUERY_ADD_AGENT_BLOBLET = GQL.gql"""
mutation addAgentBloblet($id: UUID!, $label: String!, $val: String!) {
  addAgentBloblet(AgentId: $id, input: {label: $label, val: $val}) {
    label
    val
  }
}
"""
