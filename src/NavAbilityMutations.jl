module NavAbilityMutations

export MUTATION_ADDVARIABLE = """
mutation addVariable (\$variable: FactorGraphInput!) {
    addVariable(variable: \$variable)
}
"""

export MUTATION_ADDFACTOR = """
mutation addFactor (\$factor: FactorGraphInput!) {
  addFactor(factor: \$factor)
}
"""

export MUTATION_SOLVESESSION = """
mutation solveSession (\$client: ClientInput!) {
  solveSession(client: \$client)
}
"""

export MUTATION_SOLVEFEDERATED = """
mutation solveFederated (\$scope: ScopeInput!) {
  solveFederated(scope: \$scope)
}
"""

export MUTATION_DEMOCANONICALHEXAGONAL = """
mutation demoCanonicalHexagonal (\$client: ClientInput!) {
  demoCanonicalHexagonal(client: \$client)
}
"""


end