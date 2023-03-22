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
query get_ppe(
  \$userId: ID!
  \$robotId: ID!
  \$sessionId: ID!
  \$variableId: ID!
  \$solveKey: String!
) {
  users(where: { id: \$userId }) {
    robots(where: { id: \$robotId }) {
      sessions(where: { id: \$sessionId }) {
        variables(where: { id: \$variableId }) {
          ppes(where: { solveKey_MATCHES: \$solveKey }) {
            ...ppe_fields
          }
        }
      }
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

# GQL_UPDATE_PPE = """
# $(GQL_FRAGMENT_PPES)
# mutation updatePPE(\$ppe: PPEUpdateInput!, \$uniqueKey: String!) {
#   updatePpes(
#     update: \$ppe
#     where: {uniqueKey: \$uniqueKey}
#   ) {
#     ppes {
#       ...ppe_fields
#     }
#   }
# }
# """

# GQL_DELETE_PPE = """
# mutation deletePPE(\$uniqueKey: String!) {
#   deletePpes(
#     where: {uniqueKey: \$uniqueKey}
#   ) {
#     nodesDeleted
#   }
# }
# """

# GQL_DELETE_PPE_FOR_SESSION = """
# mutation deletePPEForSession(\$sessionId: ID!, \$solveKey: ID!) {
#   deletePpes(
#     where: {
#       solveKey: \$solveKey, 
#       variable: { session: { id: \$sessionId } }
#     }) {
#     nodesDeleted
#   }
# }
# """
