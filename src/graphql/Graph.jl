QUERY_GET_GRAPH = GQL.gql"""
query getGraph($fgId: ID!) {
  factorgraphs (where: {id: $fgId}) {
    label
    createdTimestamp
    namespace
  }
}
"""

MUTATION_ADD_GRAPH = GQL.gql"""
mutation addGraph(
    $orgId: ID = ""
    $id: ID = "",
    $label: String = "",
    $description: String = "",
    $metadata: String = "",
    $_version: String = "",
) {
  addFactorgraphs(
    input: {id: $id, label: $label, _version: $_version, description: $description, metadata: $metadata, org: {connect: {where: {node: {id: $orgId}}}}}
  ) {
    factorgraphs {
        label
        createdTimestamp
        namespace
    }
  }
}
"""

MUTATION_DELETE_GRAPH = GQL.gql"""
mutation deleteGraph($id: ID!) {
  deleteFactorgraphs(
    where: { id: $id }
    delete: {
      blobEntries: {
        where: { node: { parentConnection: {Factorgraph: {node: {id: $id } } } } }
      }
    }
  ) {
    nodesDeleted
    relationshipsDeleted
  }
}
"""

QUERY_LIST_GRAPHS = GQL.gql"""
query listGraphs($id: ID!) {
    orgs(where: {id: $id}) {
        fgs {
            label
        }
    }
}
"""

QUERY_GET_GRAPH_METADATA = GQL.gql"""
query getGraphMetadata($id: ID!) {
    factorgraphs(where: {id: $id}) {
        metadata
    }
}
"""

MUTATION_SET_GRAPH_METADATA = GQL.gql"""
mutation setGraphMetadata($id: ID!, $meta: String!) {
  updateFactorgraphs(
    where: { id: $id }
    update: { metadata: $meta }
  ) {
    factorgraphs {
      metadata
    }
  }
}
"""

GQL_CONNECT_GRAPH_TO_MODEL = GQL.gql"""
mutation connectGraphModel($modelId: ID!, $fgId: ID!) {
  updateModels(
    where: { id: $modelId }
    update: { fgs: { connect: { where: { node: { id: $fgId } } } } }
  ) {
    info {
      relationshipsCreated
    }
  }
}
"""

GQL_CONNECT_GRAPH_TO_AGENT = GQL.gql"""
mutation connectGraphModel($agentId: ID!, $fgId: ID!) {
  updateAgents(
    where: { id: $agentId }
    update: { fgs: { connect: { where: { node: { id: $fgId } } } } }
  ) {
    info {
      relationshipsCreated
    }
  }
}
"""

QUERY_GET_GRAPHS_AGENTS = GQL.gql"""
query getAgents_Graph($id: ID!) {
  factorgraphs(where: {id: $id}) {
    agents {
      label
      namespace
    }
  }
}
"""

QUERY_GET_GRAPH_TAGS = GQL.gql"""
query getGraphTags($id: ID!) {
  factorgraphs(where: {id: $id}) {
    tags
  }
}
"""

MUTATION_SET_GRAPH_TAGS = GQL.gql"""
mutation setGraphTags($id: ID!, $tags: [String!]!) {
  updateFactorgraphs(where: {id: $id}, update: {tags: $tags}) {
    factorgraphs {
      tags
    }
  }
}
"""

MUTATION_PUSH_GRAPH_TAGS = GQL.gql"""
mutation pushGraphTags($id: ID!, $tags_PUSH: [String!]!) {
  updateFactorgraphs(where: {id: $id}, update: {tags_PUSH: $tags_PUSH}) {
    factorgraphs {
      tags
    }
  }
}
"""