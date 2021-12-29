QUERY_VARIABLE_LABELS = """
  query VariableLabels (\$userId: ID, \$robotId: ID, \$sessionId: ID) {
    SESSION(id:\$sessionId,filter:{robot:{id:\$robotId,user:{id:\$userId}}}) {
        id
        name
        variables {
        label
        }
    }
  }"""

QUERY_FILES = """
  query Files {
    files {
      id
      filename
    }
  }"""

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

MUTATION_CREATE_UPLOAD = """
  mutation CreateUpload (\$file: FileInput!, \$parts: Int) {
    createUpload(file: \$file, parts: \$parts) {
      uploadId
      file {
        id
        filename
        filesize
      }
      parts {
        partNumber
        url
      }
    }
  }"""

MUTATION_ABORT_UPLOAD = """
  mutation AbortUpload (\$fileId: ID!, \$uploadId: ID!) {
    abortUpload(fileId: \$fileId, uploadId: \$uploadId)
  }"""

MUTATION_COMPLETE_UPLOAD = """
  mutation CompleteUpload (\$fileId: ID!, \$completedUpload: CompletedUploadInput!) {
    completeUpload(fileId: \$fileId, completedUpload: \$completedUpload)
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