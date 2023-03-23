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

import GraphQLClient as GQL

# explicitly use any DFG function to make it easier if it needs to be removed
import DistributedFactorGraphs as DFG
using DistributedFactorGraphs:
    PackedVariable, PackedVariableNodeData, MeanMaxPPE, BlobEntry, PackedFactor

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
include("services/Variable.jl")
include("services/Factor.jl")
include("services/BlobEntry.jl")
include("services/BlobStore.jl")
include("services/StandardAPI.jl")

include("services/AsyncCalls.jl")

include("Deprecated.jl")

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
