module NavAbilitySDK

# Graphql
include("./navability/graphql/Factor.jl")
include("./navability/graphql/Variable.jl")
export GQL_FRAGMENT_FACTORS, GQL_GETFACTOR, GQL_GETFACTORS, GQL_GETFACTORSFILTERED
export GQL_FRAGMENT_VARIABLES, GQL_GETVARIABLE, GQL_GETVARIABLES, GQL_GETVARIABLESFILTERED

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
include("./navability/entities/Variable.jl")
include("./navability/entities/Factor.jl")
export NavAbilityClient, NavAbilityWebsocketClient, NavAbilityHttpsClient, QueryOptions, MutationOptions
export Client, Scope
export QueryDetail, LABEL, SKELETON, SUMMARY, FULL
export VariableType, Variable
export FactorData, PriorPose2Data, Pose2Pose2Data, Pose2AprilTag4CornersData
export FactorType, Factor

# Services
include("./navability/services/Variable.jl")
include("./navability/services/Factor.jl")
include("./navability/services/Solve.jl")
export getVariable, getVariables, listVariables, ls
export addVariable, addPackedVariable
export getFactor, getFactors, listFactors, lsf
export addFactor, addPackedFactor
export solveSession, solveFederated

end