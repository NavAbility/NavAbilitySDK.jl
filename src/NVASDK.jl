module NavAbility


# object name NVA



## create objects

mutable struct NVADFG <: AbstractDFG


end


# https://github.com/JuliaRobotics/DistributedFactorGraphs.jl/blob/master/src/services/AbstractDFG.jl#L211-L309

# this is high level API
nfg = NVADFG("api.navability.io")


function addVariable!(dfg::NVADFG, variable::AbstractDFGVariable)
  error("addVariable! not implemented for $(typeof(dfg))")
end



function addFactor!(nfg::NVADFG, factor::AbstractDFGFactor)

end


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



end

#