# =========================================================================================
# State CRUD
# =========================================================================================

function DFG.getState(
    fgclient::NavAbilityDFG,
    variableLabel::Symbol,
    solveKey::Symbol = :default,
)
    id = getId(fgclient.fg, variableLabel, solveKey)

    T = Vector{DFG.State}

    response = executeGql(fgclient, GQL_OPS[:getState], (id = id,), T)

    return handleQuery(response, :states, solveKey)
end

function DFG.getStates(fgclient::NavAbilityDFG, variableLabel::Symbol)
    id = getId(fgclient.fg, variableLabel)
    T = Vector{@NamedTuple{states::Vector{DFG.State}}}

    response = executeGql(fgclient, GQL_OPS[:getStates], (id = id,), T)

    return handleQuery(response, :variables, :states)[1]
end

function DFG.addState!(
    fgclient::NavAbilityDFG,
    variableLabel::Symbol,
    vnd::DFG.State,
)
    return addState!(fgclient, variableLabel, [vnd])[1]
end

function DFG.addState!(
    fgclient::NavAbilityDFG,
    variableLabel::Symbol,
    vnds::Vector{<:DFG.State},
)
    input = map(vnds) do vnd
        createInput(fgclient, variableLabel, vnd)
    end

    T = @NamedTuple{states::Vector{State}}

    response = executeGql(fgclient, GQL_OPS[:addStates], (states = input,), T)

    return handleMutate(response, :addStates, :states)
end

#TODO add if not exist, should now be easy as the id is deterministic
function DFG.mergeState!(
    fgclient::NavAbilityDFG,
    varLabel::Symbol,
    vnd::DFG.State,
)
    id = getId(fgclient.fg, varLabel, vnd.label)

    state = StructUtils.make(Dict{Symbol, Any}, vnd, DFG.DFGJSONStyle())
    pop!(state, :id, nothing)
    pop!(state, :label, nothing)
    # Wrap values in Neo4j scalar mutation format: { set: <value> }
    for (k, v) in state
        state[k] = Dict(:set => v)
    end

    T = @NamedTuple{states::Vector{State}}

    #FIXME updateState -> mergeState
    response = executeGql(fgclient, GQL_OPS[:updateState], (state = state, id = id), T)

    return handleMutate(response, :updateStates, :states)[1]
end

function DFG.deleteState!(
    fgclient::NavAbilityDFG,
    varLabel::Symbol,
    label::Symbol,
)
    id = getId(fgclient.fg, varLabel, label)

    response = executeGql(fgclient, GQL_OPS[:deleteState], (id = id,))

    return response[:deleteStates].nodesDeleted
end

function DFG.listStates(fgclient::NavAbilityDFG, variableLabel::Symbol)
    id = getId(fgclient.fg, variableLabel)

    T = Vector{Dict{String, Vector{@NamedTuple{label::Symbol}}}}

    response = executeGql(fgclient, GQL_OPS[:listStates], (id = id,), T)

    return last.(handleQuery(response, :variables, variableLabel)["states"])
end
