MUTATION_ADDVARIABLE = """
mutation addVariable (\$variable: FactorGraphInput!) {
    addVariable(variable: \$variable)
}
"""

MUTATION_ADDFACTOR = """
mutation addFactor (\$factor: FactorGraphInput!) {
  addFactor(factor: \$factor)
}
"""

MUTATION_ADDSESSIONDATA = """
mutation addSessionData (\$sessionData: SessionData!) {
  addSessionData(sessionData: \$sessionData)
}
"""

MUTATION_SOLVESESSION = """
mutation solveSession (\$client: ClientInput!) {
  solveSession(client: \$client)
}
"""

MUTATION_SOLVEFEDERATED = """
mutation solveFederated (\$scope: ScopeInput!) {
  solveFederated(scope: \$scope)
}
"""

MUTATION_DEMOCANONICALHEXAGONAL = """
mutation demoCanonicalHexagonal (\$client: ClientInput!) {
  demoCanonicalHexagonal(client: \$client)
}
"""