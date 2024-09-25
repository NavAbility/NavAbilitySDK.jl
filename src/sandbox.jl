GQL_ADD_ORG = GQL.gql"""
mutation addOrg($label: String!, $description: String = "") {
  createOrgs(input: {label: $label, description: $description}) {
    orgs {
      id
      label
      description
    }
  }
}
"""

GQL_GET_ORG = GQL.gql"""
query getOrg($label: String!) {
  orgs(where: {label: $label}) {
    id
    label
    description
  }
}
"""

function getOrg(client::GQL.Client, label::Symbol)
  variables = Dict("label" => label)
  T = Vector{Org}
  response =
      GQL.execute(client, GQL_GET_ORG, T; variables, throw_on_execution_error = true)
  return response.data["orgs"][1]
end


## model
# models: {connect: {where: {node: {id: $id2}}}}}
GQL_ADD_MODEL = GQL.gql"""
mutation addModel(
  $id: ID = "",
  $label: String = "",
  $status: String = "",
  $tags: [String!] = "",
  $description: String = "",
  $metadata: Metadata = "",
  $namespace: ID! = ""
) 
{
  createModels(
    input: {id: $id,
      label: $label,
      status: $status,
      tags: $tags,
      description: $description,
      metadata: $metadata,
      org: {connect: {where: {node: {id: $namespace}}}}
    }
  ) {
    models {
      createdTimestamp
      description
      id
      label
      lastUpdatedTimestamp
      metadata
      namespace
      status
      tags
    }
    info {
      nodesCreated
      relationshipsCreated
    }
  }
}
"""