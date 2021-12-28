gql_addVariable = """
mutation addVariable ($variable: FactorGraphInput!) {
    addVariable(variable: $variable)
}
"""

gql_addFactor = """
mutation addFactor ($factor: FactorGraphInput!) {
  addFactor(factor: $factor)
}
"""

gql_solveSession = """
mutation solveSession ($client: ClientInput!) {
  solveSession(client: $client)
}
"""

gql_getStatusMessages = """
        query getStatusMessages($id: ID!) {
            statusMessages(id: $id) {
                requestId,
                action,
                state,
                timestamp,
                client {
                    userId,
                    robotId,
                    sessionId
                }
            }
        }
"""
