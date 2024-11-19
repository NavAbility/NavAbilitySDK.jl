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
                    parent = (Variable = createConnect(varId),),
                    blobId = if isnothing(entry.blobId)
                        entry.originId
                    else
                        entry.blobId
                    end,
                    size = isnothing(entry.size) ? "" : entry.size,
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

function DFG.addVariable!(fgclient::NavAbilityDFG, v::Variable)
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

function DFG.addVariables!(
    fgclient::NavAbilityDFG,
    vars::Vector{Variable};
    chunksize::Int = 20,
    showprogress::Bool = length(vars) > 1000,
)
    #
    addvars = VariableCreateInput.(fgclient, vars)

    # Chunk it at chunksize per call
    chunks = collect(Iterators.partition(addvars, chunksize))

    T = @NamedTuple{variables::Vector{Variable}}

    newVarReturns = @showprogress enabled = showprogress asyncmap(chunks) do c
        response =
            executeGql(fgclient, GQL_ADD_VARIABLES, Dict("variablesToCreate" => c), T;)
        handleMutate(response, "addVariables", :variables)
    end

    return reduce(vcat, newVarReturns)
end

function DFG.getVariables(fgclient::NavAbilityDFG)
    fgId = NvaSDK.getId(fgclient.fg)

    variables = Dict("fgId" => fgId, "fields_summary" => true, "fields_full" => true)

    T = Vector{Dict{String, Vector{Variable}}}

    response = executeGql(fgclient, GQL_GET_VARIABLES, variables, T)

    return handleQuery(response, "factorgraphs", fgclient.fg.label)["variables"]
end

function DFG.getVariables(fgclient::NavAbilityDFG, labels::Vector{Symbol})
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

function DFG.listVariables(
    fgclient::NavAbilityDFG,
    regexFilter::Union{Nothing, Regex} = nothing;
    tags::Vector{Symbol} = Symbol[],
    solvable::Union{Int, Nothing} = nothing,
    solvableFilter::Union{Nothing, Base.Fix2} = isnothing(solvable) ? nothing :
                                                >=(solvable),
    typeFilter::Union{Nothing, Type{<:InferenceVariable}} = nothing,
)
    #TODO deprecate solvable "solvable::Int is deprecated, use solvableFilter = >=(solvable) instead"
    !isnothing(typeFilter) && @warn("typeFilter is not implemented yet")

    fgId = NvaSDK.getId(fgclient.fg)
    variables =
        Dict("fgId" => fgId, "varwhere" => Dict{String, Union{Int, Vector{Int}, Symbol}}())

    if !isempty(tags)
        @assert length(tags) == 1 "Only one tag is currently supported in tags filter"
        variables["varwhere"]["tags_INCLUDES"] = tags[1]
    end

    if !isnothing(solvableFilter)
        if solvableFilter.f == >=
            variables["varwhere"]["solvable_GTE"] = solvableFilter.x
        elseif solvableFilter.f == >
            variables["varwhere"]["solvable_GT"] = solvableFilter.x
        elseif solvableFilter.f == <=
            variables["varwhere"]["solvable_LTE"] = solvableFilter.x
        elseif solvableFilter.f == <
            variables["varwhere"]["solvable_LT"] = solvableFilter.x
        elseif solvableFilter.f == ==
            variables["varwhere"]["solvable"] = solvableFilter.x
        elseif solvableFilter.f == in
            variables["varwhere"]["solvable_IN"] = solvableFilter.x
        else
            error("Unsupported solvableFilter function: $(solvableFilter.f)")
        end
    end

    response = executeGql(fgclient, GQL_LIST_VARIABLES, variables, Vector{Symbol})
    labels = handleQuery(response, "listVariables")

    !isnothing(regexFilter) && filter!(x -> occursin(regexFilter, string(x)), labels)

    return labels
end

function DFG.getVariable(
    fgclient::NavAbilityDFG{VT, <:AbstractDFGFactor},
    label::Symbol,
) where {VT}
    varId = NvaSDK.getId(fgclient.fg, label)

    variables = Dict("varId" => varId, "fields_summary" => true, "fields_full" => true)

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

function DFG.getVariableSummary(fgclient::NavAbilityDFG, label::Symbol)
    varId = NvaSDK.getId(fgclient.fg, label)

    variables = Dict("varId" => varId, "fields_summary" => true, "fields_full" => false)

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

function DFG.getVariableSkeleton(fgclient::NavAbilityDFG, label::Symbol)
    varId = NvaSDK.getId(fgclient.fg, label)

    variables = Dict("varId" => varId, "fields_summary" => false, "fields_full" => false)

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
function DFG.getVariablesSkeleton(fgclient::NavAbilityDFG)#, label::Symbol)
    fgId = NvaSDK.getId(fgclient.fg)

    variables = Dict("fgId" => fgId, "fields_summary" => false, "fields_full" => false)

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

function DFG.getVariablesSummary(fgclient::NavAbilityDFG)#, label::Symbol)
    fgId = NvaSDK.getId(fgclient.fg)

    variables = Dict("fgId" => fgId, "fields_summary" => true, "fields_full" => false)

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
function DFG.deleteVariable!(fgclient::NavAbilityDFG, variable::DFG.AbstractDFGVariable)
    varId = NvaSDK.getId(fgclient.fg, variable.label)

    variables = Dict("variableId" => varId)

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

function DFG.deleteVariable!(fgclient::NavAbilityDFG, label::Symbol)
    v = getVariable(fgclient, label)
    return deleteVariable!(fgclient, v)
end

## ====================
## Utilities
## ====================
#FIXME findVariable**s**NearTimestamp
function DFG.findVariableNearTimestamp(
    fgclient::NavAbilityDFG,
    timestamp::ZonedDateTime,
    window::TimePeriod,
)
    fromtime = timestamp - window
    totime = timestamp + window

    fgId = NvaSDK.getId(fgclient.fg)

    variables = Dict("fgId" => fgId, "fromTime" => fromtime, "toTime" => totime)

    response = GQL.execute(
        fgclient.client.client,
        GQL_FIND_VARIABLES_NEAR_TIMESTAMP;
        variables,
        throw_on_execution_error = true,
    )

    return Symbol.(get.(response.data["factorgraphs"][1]["variables"], "label", missing))
end

# findVariableNearTimestamp(fgclient, ZonedDateTime("2018-08-10T13:06:18.622Z"), Millisecond(100))
