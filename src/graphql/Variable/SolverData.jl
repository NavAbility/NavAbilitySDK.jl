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
  covar
  _version  
}
"""

GQL_GET_SOLVERDATA = """
$(GQL_FRAGMENT_SOLVERDATA)
query get_solver_data(
  \$id: ID!
) {
  solverData(where: { id: \$id }) {
    ...solverdata_fields
  }
}
"""

GQL_GET_SOLVERDATA_ALL = """
$(GQL_FRAGMENT_SOLVERDATA)
query get_solver_data_all(
  \$id: ID!
) {
  variables(where: { id: \$id }) {
    solverData {
      ...solverdata_fields
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

GQL_LIST_SOLVERDATA = """
query listBlobSolverData(\$id: ID!) {
  variables (
    where: {id: \$id}
  ) {
    solverData {
      solveKey
    }
  }
}
"""

GQL_UPDATE_SOLVERDATA = """
$(GQL_FRAGMENT_SOLVERDATA)
mutation updateSolverData(\$id: ID!, \$solverData: SolverDataUpdateInput!) {
  updateSolverData(
    update: \$solverData
    where: {id: \$id}
  ) {
    solverData {
      ...solverdata_fields
    }
  }
}
"""

GQL_DELETE_SOLVERDATA = GQL.gql"""
mutation deleteSolverData($id: ID!) {
  deleteSolverData(where: { id: $id }) {
    nodesDeleted
  }
}
"""

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

