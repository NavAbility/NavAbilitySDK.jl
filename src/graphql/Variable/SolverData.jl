GQL_FRAGMENT_SOLVERDATA = """
fragment solverdata_fields on SolverData {
  # Note this must be the same order as PackedVariableNodeData otherwise JSON3 will fail.
  id
  vecval
  dimval
  vecbw
  dimbw
  BayesNetOutVertIDs
  dimIDs
  dims
  eliminated
  BayesNetVertID
  separator
  variableType
  initialized
  infoPerCoord
  ismargin
  dontmargin
  solveInProgress
  solvedCount
  solveKey
  _version  
}
"""

GQL_GET_SOLVERDATA = """
$(GQL_FRAGMENT_SOLVERDATA)
query get_solver_data(
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
          solverData(where: { solveKey_MATCHES: \$solveKey }) {
            ...solverdata_fields
          }
        }
      }
    }
  }
}
"""

GQL_ADD_SOLVERDATA = """
$(GQL_FRAGMENT_SOLVERDATA)
mutation addSolverData(\$solverData: [SolverDataCreateInput!]!) {
  # Create the new ones
  addSolverData(
    input: \$solverData
  ) {
    solverData {
      ...solverdata_fields
    }
  }
}
"""

# GQL_UPDATE_SOLVERDATA = """
# $(GQL_FRAGMENT_SOLVERDATA)
# mutation updateSolverData(\$solverData: SolverDataUpdateInput!, \$uniqueKey: String!) {
#   updateSolverData(
#     update: \$solverData
#     where: {uniqueKey: \$uniqueKey}
#   ) {
#     solverData {
#       ...solverdata_fields
#     }
#   }
# }
# """

# GQL_DELETE_SOLVERDATA = """
# mutation deleteSolverData(\$uniqueKey: String!) {
#   deleteSolverData(
#     where: {uniqueKey: \$uniqueKey}
#   ) {
#     nodesDeleted
#   }
# }
# """

# GQL_DELETE_SOLVERDATA_FOR_SESSION = """
# mutation deleteSolverDataForSession(\$sessionId: ID!, \$solveKey: ID!) {
#   deleteSolverData(
#     where: {
#       solveKey: \$solveKey, 
#       variable: { session: { id: \$sessionId } }
#     }) {
#     nodesDeleted
#   }
# }
# """

