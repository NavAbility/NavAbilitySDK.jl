methodstoasync = [
    #add
    :addBlob,
    :addBlobentries!,
    :addFactor!,
    :addAgent!,
    :addAgentBlobentries!,
    :addGraph!,
    :addGraphBlobentries!,
    :addVariable!,
    :addState!,
    #get
    :getBlob,
    :getBlobentry,
    :getBlobentries,
    :getFactor,
    :getFactors,
    :getVariable,
    :getState,
    :getVariables,
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