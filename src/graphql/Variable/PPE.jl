GQL_FRAGMENT_PPES = """
fragment ppe_fields on PPE {
    # Note this must be the same order as MeanMaxPPE otherwise JSON3 will fail.
    id
    solveKey
    suggested
    max
    mean
    _type
    _version
    createdTimestamp
    lastUpdatedTimestamp
  }
"""

GQL_GET_PPE = """
$(GQL_FRAGMENT_PPES)
query get_ppe(\$id: ID!) {
  ppes(where: { id: \$id }) {
    ...ppe_fields
  }
}

"""

GQL_GET_PPES = """
$(GQL_FRAGMENT_PPES)
query get_ppes(
  \$id: ID!
) {
  variables(where: { id: \$id }) {
    ppes {
      ...ppe_fields
    }
  }
}
"""

GQL_ADD_PPES = """
$(GQL_FRAGMENT_PPES)
mutation addPpes(\$ppes: [PPECreateInput!]!) {
  addPpes(
    input: \$ppes
  ) {
    ppes {
      ...ppe_fields
    }
  }
}
"""

GQL_LIST_PPES = """
query listBlobPPEs(\$id: ID!) {
  variables (
    where: {id: \$id}
  ) {
    ppes {
      solveKey
    }
  }
}
"""

GQL_UPDATE_PPE = """
$(GQL_FRAGMENT_PPES)
mutation updatePPE(\$id: ID!, \$ppe: PPEUpdateInput!) {
  updatePpes(
    update: \$ppe
    where: {id: \$id}
  ) {
    ppes {
      ...ppe_fields
    }
  }
}
"""

GQL_DELETE_PPE = GQL.gql"""
mutation deletePPE($id: ID!) {
  deletePpes(where: { id: $id }) {
    nodesDeleted
  }
}
"""
