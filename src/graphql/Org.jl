GQL_GET_ORG = GQL.gql"""
query getOrg($label: String!) {
  orgs(where: {label: $label}) {
    id
    label
    description
  }
}
"""

GQL_GET_ORGS = GQL.gql"""
query getOrgs {
  orgs {
    id
    label
    description
  }
}
"""