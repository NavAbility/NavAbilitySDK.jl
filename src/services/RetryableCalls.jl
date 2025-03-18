retryablemethods = [
    #add
    :addBlob!,
    :addBlobEntries!,
    :addFactor!,
    :addPPEs!,
    :addAgentBlobEntries!,
    :addGraphBlobEntries!,
    :addVariable!,
    :addVariableSolverData!,
    #get
    :getBlob,
    :getBlobEntry,
    :getBlobEntries,
    :getFactor,
    :getFactors,
    :getPPE,
    :getAgentMetadata,
    :getVariable,
    :getVariableSkeleton,
    :getVariableSolverData,
    :getVariableSummary,
    :getVariables,
    :getVariablesSkeleton,
    #list
    :ls,
]

#TODO test
for met in retryablemethods
    retrymet = Symbol("retry_", met)
    # TODO retry_exceptions = 
    @eval begin
        function $retrymet(args...; n_retries = 3, kwargs...)
            while n_retries > 0
                try
                    return NavAbilitySDK.$met(args...; kwargs...)
                catch e
                    if n_retries == 1
                        rethrow(e)
                    end
                    @warn "Retrying $(string($met)) after error: $e)"
                    n_retries -= 1
                end
            end
        end
    end
end


macro retryable(n_retries::Int, expr)
    rfn =  Symbol("retry_", expr.args[1])
    return esc(:(NavAbilitySDK.$rfn($(expr.args[2:end]...), n_retries = $n_retries)))
end
