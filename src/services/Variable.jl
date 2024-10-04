# =======================================================================================
# Variable CRUD
# =======================================================================================

function VariableCreateInput(fgclient::NavAbilityDFG, v::Variable)
    # copy from a packed variable
    variableLabel = v.label

    fgId = NvaSDK.getId(fgclient.fg)
    varId = NvaSDK.getId(fgclient.fg, variableLabel)

    if isempty(v.blobEntries)
        blobEntries = nothing
    else
        blobEntryNodes = map(v.blobEntries) do entry
            Dict(
                "node" => BlobEntryCreateInput(;
                    getCommonProperties(BlobEntryCreateInput, entry)...,
                    id = getId(fgclient.fg, variableLabel, entry.label),
                    parent = (Variable=createConnect(varId),),
                    blobId = if isnothing(entry.blobId)
                        entry.originId
                    else
                        entry.blobId
                    end,
                ),
            )
        end
        blobEntries = Dict("create" => blobEntryNodes)
    end

    if isempty(v.solverData)
        solverData = nothing
    else
        solverDataNodes = map(v.solverData) do sd
            Dict(
                "node" => SolverDataCreateInput(;
                    getCommonProperties(SolverDataCreateInput, sd)...,
                    id = getId(fgclient.fg, variableLabel, sd.solveKey),
                    variable = createConnect(varId),
                ),
            )
        end
        solverData = Dict("create" => solverDataNodes)
    end

    if isempty(v.ppes)
        ppes = nothing
    else
        ppeNodes = map(v.ppes) do ppe
            Dict(
                "node" => PPECreateInput(;
                    getCommonProperties(PPECreateInput, ppe)...,
                    id = getId(fgclient.fg, variableLabel, ppe.solveKey),
                    variable = createConnect(varId),
                ),
            )
        end
        ppes = Dict("create" => ppeNodes)
    end

    label = string(v.label)
    variableType = v.variableType
    nstime = v.nstime
    solvable = v.solvable
    tags = string.(v.tags)
    metadata = v.metadata
    timestamp = string(v.timestamp)

    fg = createConnect(fgId)

    addvar = VariableCreateInput(;
        # TODO replace with `getCommonProperties(VariableCreateInput, v)...` when types updated
        id = varId,
        label,
        variableType,
        nstime,
        solvable,
        tags,
        metadata,
        timestamp,
        # to here
        #parent
        fg,
        #children
        blobEntries,
        solverData,
        ppes,
    )
    return addvar
end

function addVariable!(fgclient::NavAbilityDFG, v::Variable)
    addvar = VariableCreateInput(fgclient, v)

    variables = Dict("variablesToCreate" => [addvar])

    T = @NamedTuple{variables::Vector{Variable}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_ADD_VARIABLES,
        T; #FIXME use VariableResponse named tuple
        # VariableResponse;
        variables,
        throw_on_execution_error = true,
    )
    return handleMutate(response, "addVariables", :variables)[1]
end

function addVariables!(fgclient::NavAbilityDFG, vars::Vector{Variable}; chunksize=20)
    #
    addvars = VariableCreateInput.(fgclient, vars)

    # Chunk it at around 20 per call
    chunks = collect(Iterators.partition(addvars, chunksize))
    length(chunks) > 1 && @info "Adding variables in $(length(chunks)) batches"

    T = @NamedTuple{variables::Vector{Variable}}

    newVarReturns = Variable[]
    # p = Progress(length(chunks))
    Threads.@threads for c in chunks
        # ProgressMeter.next!(p; showvalues = [("adding", "$(c[1].label)...$(c[end].label)")])

        variables = Dict("variablesToCreate" => c)

        response = GQL.execute(
            fgclient.client.client,
            GQL_ADD_VARIABLES,
            T;
            # VariableResponse;
            variables,
            throw_on_execution_error = true,
        )
        append!(newVarReturns, response.data["addVariables"].variables)
    end

    return newVarReturns
end

function getVariables(fgclient::NavAbilityDFG)
    
    fgId = NvaSDK.getId(fgclient.fg)

    variables = Dict(
        "fgId" => fgId,
        "fields_summary" => true,
        "fields_full" => true,
    )

    T = Vector{Dict{String, Vector{Variable}}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_GET_VARIABLES,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return handleQuery(response, "factorgraphs", fgclient.fg.label)["variables"]

end

function getVariables(fgclient::NavAbilityDFG, labels::Vector{Symbol})

    namespace = fgclient.fg.namespace
    fgLabel = fgclient.fg.label

    variables = Dict(
        "variableIds" => getId.(namespace, fgLabel, labels),
        "fields_summary" => true,
        "fields_full" => true,
    )

    response = GQL.execute(
        fgclient.client.client,
        GQL_GET_VARIABLES_BY_IDS,
        Vector{Variable};
        variables,
        throw_on_execution_error = true,
    )
    return handleQuery(response, "variables")
end

function listVariables(fgclient::NavAbilityDFG)
    
    fgId = NvaSDK.getId(fgclient.fg)

    variables = Dict(
        "fgId" => fgId
    )

    T = Vector{Dict{String, Vector{@NamedTuple{label::Symbol}}}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_LIST_VARIABLES,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return last.(handleQuery(response, "factorgraphs", fgclient.fg.label)["variables"])

end

function getVariable(fgclient::NavAbilityDFG{VT, <:AbstractDFGFactor}, label::Symbol) where VT

    varId = NvaSDK.getId(fgclient.fg, label)

    variables = Dict(
        "varId" => varId,
        "fields_summary" => true,
        "fields_full" => true,
    )

    T = Vector{Variable}

    response = GQL.execute(
        fgclient.client.client,
        GQL_GET_VARIABLE,
        T;
        variables,
        throw_on_execution_error = true,
    )
    return VT(handleQuery(response, "variables", label))
end

function getVariableSummary(fgclient::NavAbilityDFG, label::Symbol)

    varId = NvaSDK.getId(fgclient.fg, label)

    variables = Dict(
        "varId" => varId,
        "fields_summary" => true,
        "fields_full" => false,
    )

    T = Vector{DFG.DFGVariableSummary}

    response = GQL.execute(
        fgclient.client.client,
        GQL_GET_VARIABLE,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return handleQuery(response, "variables", label)
end

function getVariableSkeleton(fgclient::NavAbilityDFG, label::Symbol)

    varId = NvaSDK.getId(fgclient.fg, label)

    variables = Dict(
        "varId" => varId,
        "fields_summary" => false,
        "fields_full" => false,
    )

    T = Vector{DFG.SkeletonDFGVariable}

    response = GQL.execute(
        fgclient.client.client,
        GQL_GET_VARIABLE,
        T;
        variables,
        throw_on_execution_error = true,
    )
    
    return handleQuery(response, "variables", label)
end

##
function getVariablesSkeleton(fgclient::NavAbilityDFG)#, label::Symbol)

    fgId = NvaSDK.getId(fgclient.fg)
    
    variables = Dict(
        "fgId" => fgId,
        "fields_summary" => false,
        "fields_full" => false,
    )
    
    T = Vector{@NamedTuple{variables::Vector{DFG.SkeletonDFGVariable}}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_GET_VARIABLES,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return handleQuery(response, "factorgraphs", :variables)[1]

end

function getVariablesSummary(fgclient::NavAbilityDFG)#, label::Symbol)
 
    fgId = NvaSDK.getId(fgclient.fg)
    
    variables = Dict(
        "fgId" => fgId,
        "fields_summary" => true,
        "fields_full" => false,
    )
    
    T = Vector{@NamedTuple{variables::Vector{DFG.DFGVariableSummary}}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_GET_VARIABLES,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return handleQuery(response, "factorgraphs", :variables)[1]
end

# delete variable and its satelites (by variable id)
function deleteVariable!(fgclient::NavAbilityDFG, variable::DFG.AbstractDFGVariable)

    varId = NvaSDK.getId(fgclient.fg, variable.label)

    variables = Dict(
        "variableId" => varId,
    )

    response = GQL.execute(
        fgclient.client.client,
        GQL_DELETE_VARIABLE;
        variables,
        throw_on_execution_error = true,
    )

    #FIXME return neighboring factors that got deleted
    neigfacs = Nothing[]

    return variable, neigfacs
end

function deleteVariable!(fgclient::NavAbilityDFG, label::Symbol)
    v = getVariable(fgclient, label)
    return deleteVariable!(fgclient, v)
end

## ====================
## Utilities
## ====================
#FIXME findVariable**s**NearTimestamp
function findVariableNearTimestamp(
    fgclient::NavAbilityDFG,
    timestamp::ZonedDateTime,
    window::TimePeriod,
)
    fromtime = timestamp - window
    totime = timestamp + window

    fgId = NvaSDK.getId(fgclient.fg)
    
    variables = Dict(
        "fgId" => fgId,
        "fromTime" => fromtime,
        "toTime" => totime,
    )

    response = GQL.execute(
        fgclient.client.client,
        GQL_FIND_VARIABLES_NEAR_TIMESTAMP;
        variables,
        throw_on_execution_error = true,
    )

    return Symbol.(
        get.(
            response.data["factorgraphs"][1]["variables"],
            "label",
            missing,
        )
    )
end

# findVariableNearTimestamp(fgclient, ZonedDateTime("2018-08-10T13:06:18.622Z"), Millisecond(100))
