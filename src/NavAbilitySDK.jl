module NavAbilitySDK

# Include archived exports
using Reexport
include("./archive/NavAbilitySDK.jl")
@reexport using .ArchivedNavAbilitySDK

import .ArchivedNavAbilitySDK.getVariable # Don't want to override with new implementations
import .ArchivedNavAbilitySDK.ls # Don't want to override with new implementations
import .ArchivedNavAbilitySDK.getFactor # Don't want to override with new implementations
import .ArchivedNavAbilitySDK.lsf # Don't want to override with new implementations
import .ArchivedNavAbilitySDK.getFactors # Don't want to override with new implementations

# Low-level
include("./navability/entities/Queries.jl")
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
include("./navability/entities/Variable.jl")
include("./navability/entities/Factor.jl")
export NavAbilityClient, NavAbilityWebsocketClient, NavAbilityHttpsClient, QueryOptions, MutationOptions
export Client, Scope
export VariableType, Variable
export FactorData, PriorPose2Data, Pose2Pose2Data, Pose2AprilTag4CornersData
export FactorType, Factor

# Services
include("./navability/services/Variable.jl")
include("./navability/services/Factor.jl")
include("./navability/services/Solve.jl")
export getVariable, getVariables, ls
export addVariable
export getFactor, getFactors, lsf
export addFactor
export solveSession, solveFederated

end