QUERY_CALIBRATION = """
  query Calibration(\$fileId: ID!) {
    calibration(fileId: \$fileId) {
      placeholder
    }
  }"""

MUTATION_ADDVARIABLE = """
  mutation addVariable (\$variable: FactorGraphInput!) {
    addVariable(variable: \$variable)
  }"""

MUTATION_ADDFACTOR = """
  mutation addFactor (\$factor: FactorGraphInput!) {
    addFactor(factor: \$factor)
  }"""

MUTATION_ADDSESSIONDATA = """
  mutation addSessionData (\$sessionData: SessionData!) {
    addSessionData(sessionData: \$sessionData)
  }"""

MUTATION_SOLVESESSION = """
  mutation solveSession (\$client: ClientInput!) {
    solveSession(client: \$client)
  }"""

MUTATION_SOLVEFEDERATED = """
  mutation solveFederated (\$scope: ScopeInput!) {
    solveFederated(scope: \$scope)
  }"""

MUTATION_DEMOCANONICALHEXAGONAL = """
  mutation demoCanonicalHexagonal (\$client: ClientInput!) {
    demoCanonicalHexagonal(client: \$client)
  }"""

MUTATION_PROC_CALIBRATION = """
  mutation ProcessCalibration (\$fileId: ID!) {
    procCalibration(fileId: \$fileId)
  }"""

SUBSCRIPTION_UPDATES = """
  subscription TrackEvents(\$client: ClientInput!) {
    mutationUpdate(client: \$client) {
      requestId,
      action,
      state,
      timestamp
    }
  }"""