GQL_ADD_ORG = GQL.gql"""
mutation addOrg($label: String!, $description: String = "") {
  addOrgs(input: {label: $label, description: $description}) {
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

GQL_GET_ORGS = GQL.gql"""
query getOrgs{
  orgs{
    id
    label
    description
  }
}
"""

function getOrgs(client::GQL.Client)
    T = Vector{Org}
    response = GQL.execute(client, GQL_GET_ORGS, T; throw_on_execution_error = true)
    return response.data["orgs"]
end
