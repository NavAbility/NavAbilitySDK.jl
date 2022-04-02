module NavAbilitySDK

# Global imports
using DocStringExtensions
using LinearAlgebra
using JSON
using UUIDs

# pass through exports used often
export diagm
export uuid4

# Graphql
include("./navability/graphql/Factor.jl")
include("./navability/graphql/Status.jl")
include("./navability/graphql/Variable.jl")

include("./navability/graphql/QueriesDeprecated.jl")
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
export NavAbilityClient, NavAbilityWebsocketClient, NavAbilityHttpsClient, QueryOptions, MutationOptions
export Client, Scope
export QueryDetail, LABEL, SKELETON, SUMMARY, FULL
export Distribution, Normal, Rayleigh, FullNormal, Uniform, Categorical
export VariableType, Variable
export FactorData, PriorData, PriorPose2Data, PriorPoint2Data, LinearRelativeData, Pose2Pose2Data, Pose2AprilTag4CornersData, Pose2Point2BearingRangeData, Point2Point2RangeData, MixtureData
export FactorType, Factor

# Services
include("./navability/services/Variable.jl")
include("./navability/services/Factor.jl")
include("./navability/services/Solve.jl")
include("./navability/services/Status.jl")
include("./navability/services/Utils.jl")
export getVariable, getVariables, listVariables, ls
export addVariable, addPackedVariable
export getFactor, getFactors, listFactors, lsf
export addFactor, addPackedFactor
export solveSession, solveFederated
export getStatusMessages, getStatusLatest, getStatusesLatest
export waitForCompletion

end