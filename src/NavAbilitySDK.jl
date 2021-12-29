module NavAbilitySDK

# Include archived exports
using Reexport
include("./archive/NavAbilitySDK.jl")
@reexport using .ArchivedNavAbilitySDK

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
export NavAbilityClient, NavAbilityWebsocketClient, NavAbilityHttpsClient, QueryOptions, MutationOptions
export Client, Scope
export VariableType, Variable

# Services
include("./navability/services/Variable.jl")
export getVariable, getVariableLabels
export addVariable

end