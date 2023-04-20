methodstoasync = [
    #add
    :addBlob,
    :addBlobEntries!,
    :addFactor!,
    :addNodeBlobEntries!,
    :addPPEs!,
    :addRobot!,
    :addRobotBlobEntries!,
    :addSession!,
    :addSessionBlobEntries!,
    :addUserBlobEntries!,
    :addVariable!,
    :addVariableSolverData!,
    #get
    :getBlob,
    :getBlobEntry,
    :getBlobEntries,
    :getFactor,
    :getFactors,
    :getFncTypeName,
    :getPPE,
    :getRobotMeta,
    :getVariable,
    :getVariableSkeleton,
    :getVariableSolverData,
    :getVariableSummary,
    :getVariables,
    :getVariablesSkeleton,
]

# create async versions of methods listed
#TODO test
for met in methodstoasync
    strmet = string(met)
    if strmet[end] == '!'
        metAsync = Symbol(replace(strmet, "!"=>"Async!"))
    else
        metAsync = Symbol(met, "Async")
    end        
    @eval NavAbilitySDK $metAsync(args...; kwargs...) = schedule(Task(()->$met(args...; kwargs...)))
end