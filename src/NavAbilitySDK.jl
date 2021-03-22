module NavAbilitySDK

using JSON
using DistributedFactorGraphs

# bring into context so that we can overload calls
# This shouldn't be necessary if we call using (...AFAIK...)
import DistributedFactorGraphs: 
  AbstractDFG, 
  AbstractParams, 
  NoSolverParams, 
  addVariable!
## SEE DFG COMMON API LAYER HERE
# https://github.com/JuliaRobotics/DistributedFactorGraphs.jl/blob/master/src/services/AbstractDFG.jl#L211-L309

include("NavAbilityAPIClient.jl")

# We also should export all the exposed functionality
export
  CloudDFG,
  NavAbilityAPIClient

### ---- Everything below this line should be in other files ---- ###

## the new "DFG" type
# The {T <: AbstractParams} is the generic solver parameters. 
# I don't think we need it for the moment, but the signature needs it.
mutable struct CloudDFG{T <: AbstractParams} <: AbstractDFG{T}
  client::NavAbilityAPIClient
  # These are standard across all DFG's. I think you might 
  # want to change this, which is not a problem at all.
  # JT: these will serve as a cache in this case, if its taken out, the getters/setters can be extended 
  userId::String
  robotId::String
  sessionId::String
  description::String
end

# The show function is already implemented in DistributedFactorGraphs:CustomPrinting.jl, so making it work here.
import Base: show
function Base.show(io::IO, dfg::CloudDFG)
  summary(io, dfg)
  println(io, "\n  Host: ", dfg.client.host)
  println(io, "\n  UserId: ", dfg.userId)
  println(io, "  RobotId: ", dfg.robotId)
  println(io, "  SessionId: ", dfg.sessionId)
  println(io, "  Description: ", dfg.description)
end
Base.show(io::IO, ::MIME"text/plain", dfg::CloudDFG) = show(io, dfg)

# default constructor helper
CloudDFG(;host::String="https://api.d1.navability.io/graphql", token::Union{Nothing, <:AbstractString}="") = CloudDFG{NoSolverParams}(NavAbilityAPIClient(;host=host, token=token), "", "", "", "")

# Users build this object as counter part to `fg = LightDFG()`
dfg = CloudDFG()


# by using the DFG standardized "Packed" types (which are JSONable by design requirement) we get symmetry over multi-language SDKs


# adding DFG. to explicitly show we are overloading from `const DFG = DistributedFactorGraphs`
# In Julia we take shortcut wi, in Python, JS, we will work 
function addVariable!(dfg::CloudDFG, variable::V) where {V <: AbstractDFGVariable}
  # 1. Pack the variable
  packed = packVariable(dfg, variable)

  ## this call should be fully repeated in other languages 
  # 2. Send via NavAbilityAPIClient using the transport/API layer
  addVariable!(dfg.client, packed)

  # REFERENCE:
  # send this as Dict or JSON as "Packed" version of a `DFGVariable` type
  # purposefully have one or two fields missing for robustness, or built on receiver side.
  #   {
  #     "label": "x0",
  #     "dataEntry": "{}",
  #     "nstime": "0",
  #     "dataEntryType": "{}",
  #     "smallData": "{}",
  #     "variableType": "RoME.Pose2",
  #     "solvable": 1,
  #     "tags": "[\"VARIABLE\"]",
  #     "timestamp": "2021-03-09T20:09:46.034-05:00",
  #     "_version": "0.12.0"
  #   }
end



# function DistributedFactorGraphs.addFactor!(nfg::CloudDFG, factor)
#   token = nfg.token
#   gqlClient = GraphQLClient(nfg.host, auth="Bearer $token")
#   gqlClient.Query(NavAbilityMutations.MUTATION_ADDFACTOR,operationName="AddFactor",vars=Dict(
#             "factor" => "TODO: Generate factor"
#         ))
#   # send this as Dict or JSON as "Packed" version of DFGFactor
#   # skipped field `data` and `label` to be generated on receiver side process
#   #   {
#   #     "_version": "0.12.0",
#   #     "_variableOrderSymbols": "[\"x0\",\"l1\"]",
#   #     "tags": "[\"FACTOR\"]",
#   #     "timestamp": "2021-03-09T20:09:58.996-05:00",
#   #     "nstime": "0",
#   #     "fnctype": "Pose2Point2BearingRange",
#   #     "solvable": 1
#   #   }
# end

## ==========================================================
## Comments during call, trying to find a starting point
## ==========================================================


# JS version?
# client.addVariable(args) 
# dfg.addVariable(args)

# "more functional / dispatchy"
# addVariable(client, args)
# addVariable(dfg, args)
## SC +1, JH , DF +1, JT +1 



# # can Python unpack DFGVariable?
# SC no, JH , DF no, JT no

# # only implement the packed object in other languages (i.e PackedPose2, PackedPose2Pose2)?
# SC yes, JH, DF yes, I think there might be a need for "unpacking" to work with the data post RoME#244, such as how does a Pose2 look (x,y,theta), (we can maybe do the often used ones an leave the rest to users?)

# # does addVariable! require knowing DFGVariable? 
# SC no (knowing a packed DFGVariable), JH, DF no, JT why not in julia, no for all other sdk

# # Does the SDK only provide the high level API usage?
# SC no if DFG is high level, JH, DF unclear, JT I would say all crud, set opperations defined in ref_api is high level and a good staring point. Rest can be added if needed

# # SDK usage should be the same across languages
# SC , Jim yes, DF probably yes, JT yes with the possible exeption of unpacking the full vairable in julia
# we can look if the variable can be unpacked (eg RoME is in scope) and then skip the unpacking with a warning?

## JT
# In the other SDKs (python, java, etc) there is a container (eg. Dictionary) that will look like a Variable/Factor once deserialized in julia
# The container will probably look like a combination of skeleton, summary, full in https://juliarobotics.org/DistributedFactorGraphs.jl/latest/ref_api/

# module
end

#
