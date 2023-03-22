methodstoasync = [
    #add
    :addBlob,
    :addBlobEntries!,
    :addFactor,
    :addFactor!,
    :addNodeBlobEntries!,
    :addPPEs!,
    :addRobot,
    :addRobotBlobEntries!,
    :addSession,
    :addSessionBlobEntries!,
    :addUserBlobEntries!,
    :addVariable!,
    :addVariableSolverData!,
    #get
    :getBlob,
    :getBlobEntry,
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
    metAsync = Symbol(met, "Async")
    @eval NavAbilitySDK $metAsync(args...; kwargs...) = schedule(Task(()->$met(args...; kwargs...)))
end