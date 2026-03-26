# =======================================================================================
# Variable CRUD
# =======================================================================================
function createInput(fgclient::NavAbilityDFG, variable_connect::NamedTuple, state::State)
    return NvaSDK.CreateInput(
        getId(fgclient.fg, variableLabel, state.label),
        state,
        Dict(:variable => variable_connect),
    )
end

function createInput(fgclient::NavAbilityDFG, variableLabel::Symbol, state::State)
    varId = NvaSDK.getId(fgclient.fg, variableLabel)
    variable_connect = createConnect(varId)
    # createInput(fgclient, variable_connect, state)
    return NvaSDK.CreateInput(
        getId(fgclient.fg, variableLabel, state.label),
        state,
        Dict(:variable => variable_connect),
    )
end

function createInput(fgclient::NavAbilityDFG, v::VariableDFG)
    variableCreateInput = StructUtils.make(Dict{Symbol, Any}, v, DFG.DFGJSONStyle())

    pop!(variableCreateInput, :states)
    pop!(variableCreateInput, :blobentries)
    pop!(variableCreateInput, :bloblets)

    variableLabel = v.label

    varId = NvaSDK.getId(fgclient.fg, variableLabel)
    variable_connect = createConnect(varId)

    push!(variableCreateInput, :id => varId)
    push!(variableCreateInput, :graph => createConnect(NvaSDK.getId(fgclient.fg)))

    if !isempty(DFG.refBlobentries(v))
        blobentyNodes = map(values(DFG.refBlobentries(v))) do entry
            Dict(
                :node => NvaSDK.CreateInput(
                    getId(fgclient.fg, variableLabel, entry.label),
                    entry,
                    Dict(:parent => (Variable = variable_connect,)),
                ),
            )
        end
        blobentries = Dict(:create => blobentyNodes)
        push!(variableCreateInput, :blobentries => blobentries)
    end

    if !isempty(DFG.refStates(v))
        states = map(values(DFG.refStates(v))) do state
            Dict(:node => createInput(fgclient, variableLabel, state))
            # FIXME this one doest work yet 
            # Dict(:node => createInput(fgclient, variable_connect, state))
        end
        states = Dict(:create => states)
        push!(variableCreateInput, :states => states)
    end

    if !isempty(DFG.refBloblets(v))
        blobletNodes = map(values(DFG.refBloblets(v))) do bloblet
            (node = bloblet,)
        end
        bloblets = Dict(:create => blobletNodes)
        push!(variableCreateInput, :bloblets => bloblets)
    end

    return variableCreateInput
end

function DFG.addVariable!(fgclient::NavAbilityDFG, v::VariableDFG)
    response = executeGql(
        fgclient,
        GQL_OPS[:addVariables],
        (input = createInput(fgclient, v),),
        @NamedTuple{variables::Vector{VariableDFG}}
    )
    return handleMutate(response, :addVariables, :variables)[1]
end

function DFG.addVariables!(
    fgclient::NavAbilityDFG,
    vars::Vector{VariableDFG};
    chunksize::Int = 10,
    showprogress::Bool = length(vars) > 1000,
)
    addvars = createInput.(fgclient, vars)

    chunks = collect(Iterators.partition(addvars, chunksize))

    newVarReturns = @showprogress enabled = showprogress asyncmap(chunks) do c
        response = executeGql(
            fgclient,
            GQL_OPS[:addVariables],
            (input = c,),
            @NamedTuple{variables::Vector{VariableDFG}}
        )
        handleMutate(response, :addVariables, :variables)
    end

    return reduce(vcat, newVarReturns)
end

function DFG.getVariables(dfg::NavAbilityDFG)

    response = executeGql(
        dfg,
        GQL_OPS[:getVariables],
        (fgId = NvaSDK.getId(dfg.fg),), 
        Vector{Dict{Symbol, Vector{VariableDFG}}}
    )
    return handleQuery(response, :graphs, dfg.fg.label)[:variables]
end

function DFG.getVariables(fgclient::NavAbilityDFG, labels::Vector{Symbol})
    namespace = fgclient.fg.namespace
    fgLabel = fgclient.fg.label

    response = executeGql(
        fgclient,
        GQL_OPS[:getVariablesByIds],
        (variableIds = getId.(namespace, fgLabel, labels),),
        Vector{VariableDFG}
    )
    return handleQuery(response, :variables)
end

function DFG.listVariables(
    fgclient::NavAbilityDFG,
    regexFilter::Union{Nothing, Regex} = nothing;
    tags::Vector{Symbol} = Symbol[],
    solvableFilter::Union{Nothing, Base.Fix2} = nothing,
    typeFilter::Union{Nothing, Type{<:StateType}} = nothing,
)
    #TODO deprecate solvable "solvable::Int is deprecated, use solvableFilter = >=(solvable) instead"
    !isnothing(typeFilter) && @warn("typeFilter is not implemented yet")

    fgId = NvaSDK.getId(fgclient.fg)
    variables =
        Dict("fgId" => fgId, "varwhere" => Dict{String, Any}())

    if !isempty(tags)
        variables["varwhere"]["tags"] = Dict("in" => string.(tags))
    end

    if !isnothing(solvableFilter)
        solvableWhere = Dict{Symbol, Any}()
        if solvableFilter.f == >=
            solvableWhere[:gte] = solvableFilter.x
        elseif solvableFilter.f == >
            solvableWhere[:gt] = solvableFilter.x
        elseif solvableFilter.f == <=
            solvableWhere[:lte] = solvableFilter.x
        elseif solvableFilter.f == <
            solvableWhere[:lt] = solvableFilter.x
        elseif solvableFilter.f == ==
            solvableWhere[:eq] = solvableFilter.x
        elseif solvableFilter.f == in
            solvableWhere[:in] = solvableFilter.x
        else
            error("Unsupported solvableFilter function: $(solvableFilter.f)")
        end
        variables["varwhere"]["solvable"] = solvableWhere
    end

    response = executeGql(fgclient, GQL_OPS[:listVariables], variables, Vector{Symbol})
    labels = handleQuery(response, :listVariables)

    !isnothing(regexFilter) && filter!(x -> occursin(regexFilter, string(x)), labels)

    return labels
end

function DFG.getVariable(
    fgclient::NavAbilityDFG{VT, <:AbstractGraphFactor},
    label::Symbol,
) where {VT}

    response = executeGql(
        fgclient,
        GQL_OPS[:getVariable],
        (varId = NvaSDK.getId(fgclient.fg, label),),
        Vector{VT},
    )
    return handleQuery(response, :variables, label)
end

function DFG.getVariableSummary(fgclient::NavAbilityDFG, label::Symbol)

    response = executeGql(
        fgclient,
        GQL_OPS[:getVariableSummary],
        (id = NvaSDK.getId(fgclient.fg, label),),
        Vector{DFG.VariableSummary}
    )

    return handleQuery(response, :variables, label)
end

function DFG.getVariableSkeleton(fgclient::NavAbilityDFG, label::Symbol)
    varId = NvaSDK.getId(fgclient.fg, label)

    response = executeGql(
        fgclient,
        GQL_OPS[:getVariableSkeleton],
        (varId = varId,),
        Vector{DFG.VariableSkeleton}
    )

    return handleQuery(response, :variables, label)
end

##
function DFG.getVariablesSkeleton(fgclient::NavAbilityDFG)#, label::Symbol)
    fgId = NvaSDK.getId(fgclient.fg)

    variables = Dict("fgId" => fgId, "fields_summary" => false, "fields_full" => false)

    T = @NamedTuple{variables::Vector{DFG.VariableSkeleton}}
    response = executeGql(fgclient, GQL_OPS[:getVariablesSkeleton], variables, Vector{T})

    return handleQuery(response, :graphs, :variables)[1]
end

function DFG.getVariablesSummary(fgclient::NavAbilityDFG)#, label::Symbol)
    fgId = NvaSDK.getId(fgclient.fg)

    variables = Dict("fgId" => fgId, "fields_summary" => true, "fields_full" => false)

    T = @NamedTuple{variables::Vector{DFG.VariableSummary}}
    response = executeGql(fgclient, GQL_OPS[:getVariablesSummary], variables, Vector{T})

    return handleQuery(response, :graphs, :variables)[1]
end

function DFG.deleteVariable!(fgclient::NavAbilityDFG, label::Symbol)
    varId = NvaSDK.getId(fgclient.fg, label)

    variables = Dict("variableId" => varId)

    response = executeGql(fgclient, GQL_OPS[:deleteVariable], variables)

    return response[:deleteVariables].nodesDeleted
end

## ====================
## Utilities
## ====================
function DFG.findVariablesNearTimestamp(
    fgclient::NavAbilityDFG,
    timestamp,#FIXME::ZonedDateTime,
    window::TimePeriod,
)
    fromtime = timestamp - window
    totime = timestamp + window

    fgId = NvaSDK.getId(fgclient.fg)

    variables = Dict(:fgId => fgId, :fromTime => fromtime, :toTime => totime)

    T = @NamedTuple{variables::Vector{@NamedTuple{label::Symbol}}}
    response = executeGql(fgclient, GQL_OPS[:findVariablesNearTimestamp], variables, Vector{T})

    return last.(handleQuery(response, :graphs, :variables)[1])
end

# findVariablesNearTimestamp(fgclient, ZonedDateTime("2018-08-10T13:06:18.622Z"), Millisecond(100))

function DFG.getVariableBloblets(fgclient::NavAbilityDFG, label::Symbol)
    variables = (id = NvaSDK.getId(fgclient.fg, label),)

    T = Vector{@NamedTuple{bloblets::Vector{DFG.Bloblet}}}
    response = executeGql(fgclient, GQL_OPS[:getVariableBloblets], variables, T)

    return handleQuery(response, :variables, label).bloblets
end

function DFG.addVariableBloblet!(
    fgclient::NavAbilityDFG,
    label::Symbol,
    bloblet::DFG.Bloblet
)
    response = executeGql(
        fgclient,
        GQL_OPS[:addVariableBloblet],
        (
            id = NvaSDK.getId(fgclient.fg, label), 
            label = bloblet.label,
            val = bloblet.val
        ),
    )
    #TODO handle response
    return bloblet
end
