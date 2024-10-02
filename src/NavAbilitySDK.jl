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

import DistributedFactorGraphs as DFG
using DistributedFactorGraphs:
    Variable,
    PackedVariableNodeData,
    MeanMaxPPE,
    BlobEntry,
    PackedFactor,
    hasBlob,
    getBlobStore,
    AbstractDFGVariable,
    AbstractDFGFactor,
    AbstractParams,
    AbstractDFG,
    FactorData

import DistributedFactorGraphs:
    getFactor,
    getFactors,
    addFactor!,
    updateFactor!,
    deleteFactor!,
    listFactors,
    getVariable,
    getVariables,
    addVariable!,
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
    getSessionBlobEntry,
    getSessionBlobEntries,
    addSessionBlobEntry!,
    addSessionBlobEntries!,
    listSessionBlobEntries,
    listRobotBlobEntries,
    exists,
    listNeighbors,
    findVariableNearTimestamp
# To consider implementing 
# setSolverParams!,
# getSolverParams,
# getAddHistory,
#getUserData, # TODO should propably rename to MetaData
#setUserData!, # TODO should propably rename to MetaData
#getRobotData, # TODO should propably rename to MetaData
#setRobotData!, # TODO should propably rename to MetaData
#getSessionData, # TODO should propably rename to MetaData
#setSessionData!, # TODO should propably rename to MetaData
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
    FactorData,
    PackedVariableNodeData,
    PackedFactor

# Function exports
export addRobot!,
    addSession!,
    deleteSession!,
    deleteRobot!,
    listRobots,
    listSessions,
    getFactor,
    getFactors,
    getFactorsSkeleton,
    addFactor!,
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
    getSessionBlobEntry,
    getSessionBlobEntries,
    addSessionBlobEntries!,
    listSessionBlobEntries,
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

# TODO NvaModel vs NavAbilityModel
#  NavAbilityModel

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
