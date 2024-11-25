module NavAbilitySDK

const NvaSDK = NavAbilitySDK
export NvaSDK

using DocStringExtensions
using LinearAlgebra
using UUIDs
using Dates
using TimeZones
using JSON3
using Base64
using StructTypes
using Downloads
using HTTP
using DistributedFactorGraphs.ProgressMeter

import GraphQLClient as GQL

using DistributedFactorGraphs

using DistributedFactorGraphs: 
    Agent,
    getAgent,
    getGraph

import DistributedFactorGraphs:
    getFactor,
    getFactors,
    addFactor!,
    addFactors!,
    updateFactor!,
    deleteFactor!,
    listFactors,
    getVariable,
    getVariables,
    addVariable!,
    addVariables!,
    updateVariable!,
    deleteVariable!,
    listVariables,
    listBlobEntries,
    listPPEs,
    listVariableSolverData,
    getPPE,
    getPPEs,
    addPPE!,
    updatePPE!,
    deletePPE!,
    getVariableSolverData,
    getVariableSolverDataAll,
    addVariableSolverData!,
    updateVariableSolverData!,
    deleteVariableSolverData!,
    getBlobEntry,
    getBlobEntries,
    addBlobEntry!,
    updateBlobEntry!,
    deleteBlobEntry!,
    getBlob,
    addBlob!,
    deleteBlob!,
    hasBlob,
    getGraphBlobEntry,
    getGraphBlobEntries,
    addGraphBlobEntry!,
    addGraphBlobEntries!,
    getModelBlobEntries,
    listModelBlobEntries,
    listGraphBlobEntries,
    listAgentBlobEntries,
    exists,
    listNeighbors,
    findVariableNearTimestamp,
    Agent,
    getAgent,
    getGraph,
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

include("entities/Distributions.jl")
include("entities/InferenceTypes.jl")
include("entities/VariableTypes.jl")
include("entities/NvaNodes.jl")
include("entities/Variable.jl")
include("entities/Factor.jl")

include("NavAbilityClient.jl")
include("NavAbilityDFG.jl")
include("NavAbilityModel.jl")

include("services/Common.jl")
include("services/PPE.jl")
include("services/SolverData.jl")
include("services/Variable.jl")
include("services/Factor.jl")
include("services/BlobEntry.jl")
include("services/BlobStore.jl")
include("services/StandardAPI.jl")
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
export getBlobStore

# Type exports
export NavAbilityClient,
    NavAbilityDFG,
    NavAbilityBlobStore,
    Variable,
    Factor,
    MeanMaxPPE,
    BlobEntry,
    PackedVariableNodeData,
    PackedFactor

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
    updateFactor!,
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
    updateVariable!,
    deleteVariable!,
    listVariables,
    listBlobEntries,
    listPPEs,
    listVariableSolverData,
    getPPE,
    getPPEs,
    addPPE!,
    updatePPE!,
    deletePPE!,
    getVariableSolverData,
    getVariableSolverDataAll,
    addVariableSolverData!,
    updateVariableSolverData!,
    deleteVariableSolverData!,
    getBlobEntry,
    getBlobEntries,
    addBlobEntry!,
    updateBlobEntry!,
    deleteBlobEntry!,
    getGraphBlobEntry,
    getGraphBlobEntries,
    addGraphBlobEntries!,
    listGraphBlobEntries,
    getBlob,
    addBlob!,
    deleteBlob!,
    exists,
    getNeighbors,
    listNeighbors,
    findVariableNearTimestamp,
    startWorker

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
# export ls
# export lsf
# export initVariable
# export solveSession, solveFederated
# export getStatusMessages, getStatusLatest, getStatusesLatest
# export waitForCompletion
# export exportSession, getExportSessionBlobId
# export GraphVizApp, MapVizApp

end
