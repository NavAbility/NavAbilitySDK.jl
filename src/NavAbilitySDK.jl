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

# We also should export all the exposed functionality
export 
  NVADFG

### ---- Everything below this line should be in other files ---- ###

## the new "DFG" type
# The {T <: AbstractParams} is the generic solver parameters. 
# I don't think we need it for the moment, but the signature needs it.
mutable struct NVADFG{T <: AbstractParams} <: AbstractDFG{T}
  host::String
  # At this point we should either do 3-legged Auth 
  # to get a token, but leaving that up to you, whichever
  # you think is best. Just putting a token in here for now.
  token::Union{Nothing, String}
  # These are standard across all DFG's. I think you might 
  # want to change this, which is not a problem at all.
  userId::String
  robotId::String
  sessionId::String
  description::String
end

# The show function is already implemented in DistributedFactorGraphs:CustomPrinting.jl, so making it work here.
import Base: show
function Base.show(io::IO, ::MIME"text/plain", dfg::NVADFG)
  summary(io, dfg)
  println(io, "\n  Host: ", dfg.host)
  println(io, "\n  UserId: ", dfg.userId)
  println(io, "  RobotId: ", dfg.robotId)
  println(io, "  SessionId: ", dfg.sessionId)
  println(io, "  Description: ", dfg.description)
end

# default constructor helper
NVADFG(;host::String="https://api.d1.navability.io", token::Union{Nothing, String}="") = NVADFG{NoSolverParams}(host, token, "", "", "", "")
function NVADFG(configFile::String; promptForToken::Bool = true) 
  configString = read(configFile, String)
  configData = JSON.parse(configString)
  token = nothing
  if promptForToken
    print("Token for $(configData["host"]): ")
    token = readline()
  end
  return NVADFG{NoSolverParams}(configData["host"], token, "", "", "", "")
end


# Users build this object as counter part to `fg = LightDFG()`
nfg = NVADFG()


# by using the DFG standardized "Packed" types (which are JSONable by design requirement) we get symmetry over multi-language SDKs


# adding DFG. to explicitly show we are overloading from `const DFG = DistributedFactorGraphs`
function DistributedFactorGraphs.addVariable!(dfg::NVADFG, variable)
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



function DistributedFactorGraphs.addFactor!(nfg::NVADFG, factor)
  # send this as Dict or JSON as "Packed" version of DFGFactor
  # skipped field `data` and `label` to be generated on receiver side process
  #   {
  #     "_version": "0.12.0",
  #     "_variableOrderSymbols": "[\"x0\",\"l1\"]",
  #     "tags": "[\"FACTOR\"]",
  #     "timestamp": "2021-03-09T20:09:58.996-05:00",
  #     "nstime": "0",
  #     "fnctype": "Pose2Point2BearingRange",
  #     "solvable": 1
  #   }
end







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



# module
end

#
