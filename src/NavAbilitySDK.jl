module NavAbilitySDK

using JSON
using Unmarshal
using UUIDs
using Base64
using DistributedFactorGraphs
using Diana
using DocStringExtensions

# Bring into context so that we can overload calls
import DistributedFactorGraphs: 
  AbstractDFG, 
  AbstractParams, 
  NoSolverParams, 
  addVariable!,
  addFactor!,
  copyGraph!,
  getVariable,
  getVariables,
  getFactor,
  getFactors,
  listVariables,
  listFactors,
  exists,
  getNeighbors,
  ls

include("common.jl")
include("entities/NavAbilityAPIClient.jl")
include("entities/CloudDFG.jl")
include("services/NavAbilityAPIClient.jl")
include("services/NavAbilityQueries.jl")
include("services/CloudDFG.jl")

import NavAbilitySDK.Queries: 
  gql_ls, 
  gql_lsf, 
  gql_getVariables, 
  gql_getFactors,
  gql_getNodes,
  gql_getStatusMessages,
  gql_getStatusLatest

# We also should export all the exposed functionality
export
  CloudDFG,
  NavAbilityAPIClient,
  ScopeInput,
  NavAbilityGQLClient,
  StatusMessage,
  login,
  graphQuery,
  solveSession!,
  solveFederated!,
  getStatusMessages,
  getStatusLatest

# The show function is already implemented in DistributedFactorGraphs:CustomPrinting.jl, so making it work here.
import Base: show
# Used to extract the cognito user from the token during login.
import JSONWebTokens: base64url_decode


# Refactoring begins here
include("./navability/entities/NavAbilityClient.jl")
export NavAbilityClient, NavAbilityWebsocketClient, NavAbilityHttpsClient

end