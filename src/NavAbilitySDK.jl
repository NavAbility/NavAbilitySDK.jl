module NavAbilitySDK

const NvaSDK = NavAbilitySDK
export NvaSDK

using DocStringExtensions
using LinearAlgebra
using UUIDs
using Dates
# using TimeZones
using JSON
using Base64
using StructUtils
using Downloads
using HTTP
using DistributedFactorGraphs.ProgressMeter

import GraphQLClient as GQL

using DistributedFactorGraphs

using DistributedFactorGraphs: 
    Agent,
    Graphroot,
    getAgent,
    getGraph,
    getId,
    assembleFactorName

import DistributedFactorGraphs:
    getFactor,
    getFactors,
    addFactor!,
    addFactors!,
    deleteFactor!,
    listFactors,
    getVariable,
    getVariables,
    addVariable!,
    addVariables!,
    deleteVariable!,
    listVariables,
    listVariableBlobentries,
    getStates,
    getVariableBlobentry,
    getVariableBlobentries,
    addVariableBlobentry!,
    mergeVariableBlobentry!,
    deleteVariableBlobentry!,
    getBlob,
    addBlob!,
    deleteBlob!,
    hasBlob,
    getGraphBlobentry,
    getGraphBlobentries,
    addGraphBlobentry!,
    addGraphBlobentries!,
    getModelBlobentries,
    listModelBlobentries,
    listGraphBlobentries,
    listAgentBlobentries,
    hasVariable,
    hasFactor,
    listNeighbors,
    findVariablesNearTimestamp,
    Agent,
    getAgent,
    getGraph,
    getGraphMetadata,
    getAgentMetadata,
    getVariablesSkeleton,
    getVariableSkeleton,
    getVariableSummary,
    getVariablesSummary,
    getFactorsSkeleton
# To consider implementing 
# setSolverParams!,
# getSolverParams,
# getAddHistory,
# isVariable,
# isFactor,
# ls,
# lsf,
# isConnected,
# buildSubgraph,
# copyGraph!,
# getBiadjacencyMatrix,

# Graphql
include("graphql/BlobEntry.jl")
include("graphql/Factor.jl")
include("graphql/Variable/Variable.jl")
include("graphql/BlobStore.jl")
include("graphql/Model.jl")
include("graphql/Agent.jl")
include("graphql/Graph.jl")
include("graphql/Org.jl")

include("entities/NvaNodes.jl")

include("NavAbilityClient.jl")
include("NavAbilityDFG.jl")
include("NavAbilityModel.jl")

include("services/Common.jl")
include("services/State.jl")
include("services/Variable.jl")
include("services/Factor.jl")
include("services/BlobEntry.jl")
include("services/BlobStore.jl")
include("services/StandardAPI.jl") #TODO can this and IIF constructors be combined in DFG?
include("services/FactorGraph.jl")
include("services/Model.jl")
include("services/Agent.jl")
include("services/Workers.jl")

include("services/AsyncCalls.jl")

include("services/Org.jl")

include("Deprecated.jl")

# LinearAlgebra pass through exports
export I, diagm, norm

# UUIDs pass through exports
export UUID, uuid4

# DFG pass through exports
export DFG

# Type exports
export NavAbilityClient,
    NavAbilityDFG,
    NavAbilityBlobStore,
    VariableDFG,
    Blobentry,
    FactorDFG

# Function exports
export addAgent!,
    addGraph!,
    deleteGraph!,
    deleteAgent!,
    listAgents,
    listGraphs,
    getFactor,
    getFactors,
    getFactorsSkeleton,
    addFactor!,
    addFactors!,
    deleteFactor!,
    listFactors,
    getVariable,
    getVariableSummary,
    getVariableSkeleton,
    getVariables,
    getVariablesSummary,
    getVariablesSkeleton,
    addVariable!,
    addVariables!,
    deleteVariable!,
    listVariables,
    listVariableBlobentries,
    listStates,
    getState,
    getStates,
    addState!,
    mergeState!,
    deleteState!,
    getVariableBlobentry,
    getVariableBlobentries,
    addVariableBlobentry!,
    mergeVariableBlobentry!,
    deleteVariableBlobentry!,
    getGraphBlobentry,
    getGraphBlobentries,
    addGraphBlobentry!,
    addGraphBlobentries!,
    listGraphBlobentries,
    getBlob,
    addBlob!,
    deleteBlob!,
    listNeighbors,
    hasVariable,
    hasFactor,
    findVariablesNearTimestamp,
    startWorker,
    getBlobstore

# Alias exports
export NvaDFG
const NvaDFG = NavAbilityDFG

#TODO 
# export NavAbilityModel, NvaModel
const NvaModel = NavAbilityModel

#old exports
# export Distribution, Normal, Rayleigh, FullNormal, Uniform, Categorical
# export ManifoldKernelDensity
# export PriorPose3, Pose3Pose3
# export SolveOptions
# export SessionKey, SessionId, ExportSessionInput, ExportSessionOptions
# export initVariable
# export solveSession, solveFederated
# export getStatusMessages, getStatusLatest, getStatusesLatest
# export waitForCompletion
# export exportSession, getExportSessionBlobId
# export GraphVizApp, MapVizApp

end
