QUERY_GET_GRAPH = GQL.gql"""
query getGraph($id: UUID!) {
  graphs (where: {id: {eq: $id}}) {
    label
    namespace
  }
}
"""

MUTATION_ADD_GRAPH = GQL.gql"""
mutation addGraphs($input: [GraphCreateInput!]!) {
  addGraphs(
    input: $input
  ) {
    graphs {
        label
        namespace
    }
  }
}
"""

MUTATION_DELETE_GRAPH = GQL.gql"""
mutation deleteGraph($id: UUID!) {
  deleteGraphs(
    where: { id: {eq: $id} }
    delete: {blobentries: {}, bloblets: {}, factors: {}, variables: {}}
  ) {
    nodesDeleted
    relationshipsDeleted
  }
}
"""

QUERY_LIST_GRAPHS = GQL.gql"""
query listGraphs($id: UUID!) {
    orgs(where: {id: {eq: $id}}) {
        graphs {
            label
        }
    }
}
"""

QUERY_GET_GRAPH_METADATA = GQL.gql"""
query getGraphMetadata($id: UUID!) {
    graphs(where: {id: {eq: $id}}) {
        metadata
    }
}
"""

MUTATION_SET_GRAPH_METADATA = GQL.gql"""
mutation setGraphMetadata($id: UUID!, $meta: String!) {
  updateGraphs(
    where: { id: {eq: $id} }
    update: { metadata: $meta }
  ) {
    graphs {
      metadata
    }
  }
}
"""

GQL_CONNECT_GRAPH_TO_MODEL = GQL.gql"""
mutation connectGraphModel($modelId: UUID!, $fgId: UUID!) {
  updateModels(
    where: { id: {eq: $modelId} }
    update: { graphs: { connect: { where: { node: { id: {eq: $fgId} } } } } }
  ) {
    info {
      relationshipsCreated
    }
  }
}
"""

GQL_CONNECT_GRAPH_TO_AGENT = GQL.gql"""
mutation connectGraphAgent($agentId: UUID!, $fgId: UUID!) {
  updateAgents(
    where: { id: {eq: $agentId} }
    update: { graphs: { connect: { where: { node: { id: {eq: $fgId} } } } } }
  ) {
    info {
      relationshipsCreated
    }
  }
}
"""

QUERY_GET_GRAPHS_AGENTS = GQL.gql"""
query getAgents_Graph($id: UUID!) {
  graphs(where: {id: {eq: $id}}) {
    agents {
      label
      namespace
    }
  }
}
"""

QUERY_GET_GRAPH_TAGS = GQL.gql"""
query listGraphTags($id: UUID!) {
  graphs(where: {id: {eq: $id}}) {
    tags
  }
}
"""

MUTATION_SET_GRAPH_TAGS = GQL.gql"""
mutation setGraphTags($id: UUID!, $tags: [String!]!) {
  updateGraphs(where: {id: {eq: $id}}, update: {tags: $tags}) {
    graphs {
      tags
    }
  }
}
"""

MUTATION_PUSH_GRAPH_TAGS = GQL.gql"""
mutation pushGraphTags($id: UUID!, $tags_PUSH: [String!]!) {
  updateGraphs(where: {id: {eq: $id}}, update: {tags_PUSH: $tags_PUSH}) {
    graphs {
      tags
    }
  }
}
"""