module NavAbilitySDK

# bring into context so that we can overload calls
import DistributedFactorGraphs
## SEE DFG COMMON API LAYER HERE
# https://github.com/JuliaRobotics/DistributedFactorGraphs.jl/blob/master/src/services/AbstractDFG.jl#L211-L309


## the new "DFG" type

mutable struct NVADFG <: AbstractDFG
  url::String
  # ...
end

# default constructor helper
NVADFG(;url="api.navability.io") = NVADFG(url)


# Users build this object as counter part to `fg = LightDFG()`
nfg = NVADFG()


# by using the DFG standardized "Packed" types (which are JSONable by design requirement) we get symmetry over multi-language SDKs


# adding DFG. to explicitly show we are overloading from `const DFG = DistributedFactorGraphs`
function DFG.addVariable!(dfg::NVADFG, variable)
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



function DFG.addFactor!(nfg::NVADFG, factor)
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
