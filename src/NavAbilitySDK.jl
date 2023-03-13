module NavAbilitySDK

const NvaSDK = NavAbilitySDK
# export NVA

# Global imports
using Diana
using DocStringExtensions
using LinearAlgebra
using JSON
using UUIDs
using Downloads
using HTTP
using Dates
using Base64

# for overloading with visualization helpers
import Base: show

# LinearAlgebra pass through exports
export diagm, norm
# UUIDs pass through exports
export uuid4


DFG_VERSION = "0.18.10";

# Graphql
include("./navability/graphql/Factor.jl")
include("./navability/graphql/Status.jl")
include("./navability/graphql/Variable.jl")
include("./navability/graphql/DataBlobs.jl")
include("./navability/graphql/Session.jl")


include("./navability/graphql/QueriesDeprecated.jl")
# TODO remove GQL exports, since users can easily just use NVA.QUERY___
export QUERY_VARIABLE_LABELS
export QUERY_FILES, QUERY_CALIBRATION
export MUTATION_ADDVARIABLE, MUTATION_ADDFACTOR, MUTATION_ADDSESSIONDATA
export MUTATION_SOLVESESSION, MUTATION_SOLVEFEDERATED
export MUTATION_DEMOCANONICALHEXAGONAL
export MUTATION_CREATE_UPLOAD, MUTATION_ABORT_UPLOAD, MUTATION_COMPLETE_UPLOAD
export MUTATION_PROC_CALIBRATION
export SUBSCRIPTION_UPDATES

# Entities
include("./navability/entities/NavAbilityClient.jl")
include("./navability/entities/Client.jl")
include("./navability/entities/Common.jl")
include("./navability/entities/Distributions.jl")
include("./navability/entities/Variable.jl")
include("./navability/entities/InferenceTypes.jl")
include("./navability/entities/Factor.jl")
include("./navability/entities/Solve.jl")
include("./navability/entities/Session.jl")
export NavAbilityClient, NavAbilityWebsocketClient, NavAbilityHttpsClient, QueryOptions, MutationOptions
export Client, Scope
export QueryDetail, LABEL, SKELETON, SUMMARY, FULL
export Distribution, Normal, Rayleigh, FullNormal, Uniform, Categorical
export ManifoldKernelDensity
export Variable
export FactorData, PriorData, PriorPose2Data, PriorPoint2Data, LinearRelativeData, Pose2Pose2Data, Pose2AprilTag4CornersData, Pose2Point2BearingRangeData, Point2Point2RangeData, MixtureData
export PriorPose3, Pose3Pose3
export ScatterAlignPose2Data
export FactorType, Factor
export SolveOptions
export SessionKey, SessionId, ExportSessionInput, ExportSessionOptions

# Services
include("./navability/services/Variable.jl")
include("./navability/services/Factor.jl")
include("./navability/services/Solve.jl")
include("./navability/services/Status.jl")
include("./navability/services/Utils.jl")
include("./navability/services/StandardAPI.jl")
include("./navability/services/DataBlobs.jl")
include("./navability/services/Session.jl")
export getVariable, getVariables, listVariables, ls
export addVariable, updateVariable, addVariablePacked, updateVariablePacked, addPackedVariable, addPackedVariableOld
export getFactor, getFactors, listFactors, lsf
export addFactor, addPackedFactor, deleteFactor
export initVariable
export listBlobEntries
export getBlobEntry, getBlob
export addBlobEntry, addBlob
export solveSession, solveFederated
export getStatusMessages, getStatusLatest, getStatusesLatest
export waitForCompletion
export exportSession, getExportSessionBlobId
export GraphVizApp, MapVizApp

include("Deprecated.jl")

end
