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

# explicitly use any DFG function to make it easier if it needs to be removed
import DistributedFactorGraphs as DFG
using DistributedFactorGraphs:
    Variable, PackedVariableNodeData, MeanMaxPPE, BlobEntry, PackedFactor

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
    exists,
    getNeighbors
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

# # LinearAlgebra pass through exports
# export diagm, norm
# # UUIDs pass through exports
# export uuid4

# Graphql
include("graphql/BlobEntry.jl")
include("graphql/UserRobotSession.jl")
include("graphql/Factor.jl")
include("graphql/Variable/Variable.jl")
include("graphql/BlobStore.jl")

include("entities/Distributions.jl")
include("entities/InferenceTypes.jl")
include("entities/UserRobotSession.jl")
include("entities/Variable.jl")
include("entities/Factor.jl")

include("NavAbilityClient.jl")

include("services/Common.jl")
include("services/UserRobotSession.jl")
include("services/PPE.jl")
include("services/SolverData.jl")
include("services/Variable.jl")
include("services/Factor.jl")
include("services/BlobEntry.jl")
include("services/BlobStore.jl")
include("services/StandardAPI.jl")
include("services/FactorGraph.jl")

include("services/AsyncCalls.jl")

include("Deprecated.jl")

export NavAbilityClient, DFGClient, NavAbilityBlobStore

export addVariables!
#DFG exports
export 
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
    addSessionBlobEnties!,
    listSessionBlobEntries,
    getBlob,
    addBlob!,
    deleteBlob!,
    exists,
    getNeighbors,
    listNeighbors,
    listVariableNeighbors,
    listFactorNeighbors

export Variable, Factor, MeanMaxPPE, BlobEntry

#exports
# export NavAbilityClient, NavAbilityWebsocketClient, NavAbilityHttpsClient, QueryOptions, MutationOptions
# export Client, Scope
# export QueryDetail, LABEL, SKELETON, SUMMARY, FULL
# export Distribution, Normal, Rayleigh, FullNormal, Uniform, Categorical
# export ManifoldKernelDensity
# export Variable
# export FactorData, PriorData, PriorPose2Data, PriorPoint2Data, LinearRelativeData, Pose2Pose2Data, Pose2AprilTag4CornersData, Pose2Point2BearingRangeData, Point2Point2RangeData, MixtureData
# export PriorPose3, Pose3Pose3
# export ScatterAlignPose2Data
# export FactorType, Factor
# export SolveOptions
# export SessionKey, SessionId, ExportSessionInput, ExportSessionOptions

# export getVariable, getVariables, listVariables, ls
# export addVariable, updateVariable, addVariablePacked, updateVariablePacked, addPackedVariable, addPackedVariableOld
# export getFactor, getFactors, listFactors, lsf
# export addFactor, addPackedFactor, deleteFactor
# export initVariable
# export listBlobEntries
# export getBlobEntry, getBlob
# export addBlobEntry, addBlob
# export solveSession, solveFederated
# export getStatusMessages, getStatusLatest, getStatusesLatest
# export waitForCompletion
# export exportSession, getExportSessionBlobId
# export GraphVizApp, MapVizApp

end
