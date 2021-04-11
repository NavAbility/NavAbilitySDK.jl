module NavAbilitySDK

using JSON
using UUIDs
using Base64
using DistributedFactorGraphs
using Diana
using DocStringExtensions

# Bring into context so that we can overload calls
import DistributedFactorGraphs: 
  AbstractDFG, 
  AbstractParams, 
  NoSolverParams, 
  addVariable!,
  addFactor!

include("common.jl")
include("entities/NavAbilityAPIClient.jl")
include("entities/CloudDFG.jl")
include("services/NavAbilityAPIClient.jl")
include("services/CloudDFG.jl")

# We also should export all the exposed functionality
export
  CloudDFG,
  NavAbilityAPIClient,
  login

### ---- Everything below this line should be in other files ---- ###

# The show function is already implemented in DistributedFactorGraphs:CustomPrinting.jl, so making it work here.
import Base: show
# Used to extract the cognito user from the token during login.
import JSONWebTokens: base64url_decode

## ==========================================================
## Comments during call, trying to find a starting point
## ==========================================================


# JS version?
# client.addVariable(args) 
# dfg.addVariable(args)

# "more functional / dispatchy"
# addVariable(client, args)
# addVariable(dfg, args)
## SC +1, JH , DF +1,



# # can Python unpack DFGVariable?
# SC no, JH , DF no

# # only implement the packed object in other languages (i.e PackedPose2, PackedPose2Pose2)?
# SC yes, JH, DF yes

# # does addVariable! require knowing DFGVariable? 
# SC no (knowing a packed DFGVariable), JH, DF no

# # Does the SDK only provide the high level API usage?
# SC no if DFG is high level, JH, DF unclear

# # SDK usage should be the same across languages
# SC , Jim yes, DF probably yes,

## JT
# In the other SDKs (python, java, etc) there is a container (eg. Dictionary) that will look like a Variable/Factor once deserialized in julia
# The container will probably look like a combination of skeleton, summary, full in https://juliarobotics.org/DistributedFactorGraphs.jl/latest/ref_api/

# module
end

#
