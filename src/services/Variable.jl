# =======================================================================================
# Variable CRUD
# =======================================================================================

function VariableCreateInput(fgclient::DFGClient, v::Variable)
    # copy from a packed variable
    variableLabel = v.label

    if isempty(v.blobEntries)
        blobEntries = nothing
    else
        blobEntryNodes = map(v.blobEntries) do entry
            Dict(
                "node" => BlobEntryCreateInput(;
                    userLabel = fgclient.user.label,
                    robotLabel = fgclient.robot.label,
                    sessionLabel = fgclient.session.label,
                    variableLabel = string(variableLabel),
                    getCommonProperties(BlobEntryCreateInput, entry)...,
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
                    userLabel = fgclient.user.label,
                    robotLabel = fgclient.robot.label,
                    sessionLabel = fgclient.session.label,
                    variableLabel = string(variableLabel),
                    variable = nothing,
                    getCommonProperties(SolverDataCreateInput, sd)...,
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
                    userLabel = fgclient.user.label,
                    robotLabel = fgclient.robot.label,
                    sessionLabel = fgclient.session.label,
                    variableLabel = string(variableLabel),
                    variable = nothing,
                    getCommonProperties(PPECreateInput, ppe)...,
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

    session = createConnect(fgclient.session.id)

    addvar = VariableCreateInput(;
        # TODO replace with `getCommonProperties(VariableCreateInput, v)...` when types updated
        label,
        variableType,
        nstime,
        solvable,
        tags,
        metadata,
        timestamp,
        # to here
        session,
        blobEntries,
        solverData,
        ppes,
        userLabel = fgclient.user.label,
        robotLabel = fgclient.robot.label,
        sessionLabel = fgclient.session.label,
    )
    return addvar
end

function addVariable!(fgclient::DFGClient, v::Variable)
    addvar = VariableCreateInput(fgclient, v)

    variables = Dict("variablesToCreate" => [addvar])

    response = GQL.execute(
        fgclient.client,
        GQL_ADD_VARIABLES,
        VariableResponse;
        variables,
        throw_on_execution_error = true,
    )

    return response.data["addVariables"].variables[1]
end

function addVariables!(fgclient::DFGClient, vars::Vector{Variable}; chunksize=20)
    #
    addvars = VariableCreateInput.(fgclient, vars)

    # Chunk it at around 20 per call
    chunks = collect(Iterators.partition(addvars, chunksize))
    length(chunks) > 1 && @info "Adding variables in $(length(chunks)) batches"

    newVarReturns = Variable[]
    # p = Progress(length(chunks))
    Threads.@threads for c in chunks
        # ProgressMeter.next!(p; showvalues = [("adding", "$(c[1].label)...$(c[end].label)")])

        variables = Dict("variablesToCreate" => c)

        response = GQL.execute(
            fgclient.client,
            GQL_ADD_VARIABLES,
            VariableResponse;
            variables,
            throw_on_execution_error = true,
        )
        append!(newVarReturns, response.data["addVariables"].variables)
    end

    return newVarReturns
end

function getVariables(fgclient::DFGClient)
    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "fields_summary" => true,
        "fields_full" => true,
    )

    T = Vector{
        Dict{String, Vector{Dict{String, Vector{Dict{String, Vector{Variable}}}}}},
    }

    response = GQL.execute(
        fgclient.client,
        GQL_GET_VARIABLES,
        T;
        variables,
        throw_on_execution_error = true,
    )
    return response.data["users"][1]["robots"][1]["sessions"][1]["variables"]
end

function getVariables(fgclient::DFGClient, label::Vector{Symbol})
    variables = Dict(
        "userLabel" => fgclient.user.label,
        "robotLabel" => fgclient.robot.label,
        "sessionLabel" => fgclient.session.label,
        "variableLabels" => string.(label),
        "fields_summary" => true,
        "fields_full" => true,
    )

    response = GQL.execute(
        fgclient.client,
        GQL_GET_VARIABLES_BY_LABELS,
        Vector{Variable};
        variables,
        throw_on_execution_error = true,
    )
    return response.data["variables"]
end

function listVariables(fgclient::DFGClient)
    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
    )

    response = GQL.execute(
        fgclient.client,
        GQL_LIST_VARIABLES;
        variables,
        throw_on_execution_error = true,
    )

    return Symbol.(
        get.(
            response.data["users"][1]["robots"][1]["sessions"][1]["variables"],
            "label",
            missing,
        )
    )
end

function getVariable(fgclient::DFGClient{VT, <:AbstractDFGFactor}, label::Symbol) where VT
    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableLabel" => string(label),
        "fields_summary" => true,
        "fields_full" => true,
    )

    T = Vector{
        Dict{String, Vector{Dict{String, Vector{Dict{String, Vector{Variable}}}}}},
    }

    response = GQL.execute(
        fgclient.client,
        GQL_GET_VARIABLE,
        T;
        variables,
        throw_on_execution_error = true,
    )
    return VT(response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1])
end

function getVariableSummary(fgclient::DFGClient, label::Symbol)
    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableLabel" => string(label),
        "fields_summary" => true,
        "fields_full" => false,
    )

    response = GQL.execute(
        fgclient.client,
        GQL_GET_VARIABLE;
        variables,
        throw_on_execution_error = true,
    )
    # return response.data["variables"][]

    jstr =
        JSON3.write(response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1])
    return JSON3.read(jstr, DFG.DFGVariableSummary)
end

#FIXME when variables query work this can be changed
function getVariableSkeleton(fgclient::DFGClient, label::Symbol)
    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableLabel" => string(label),
        "fields_summary" => false,
        "fields_full" => false,
    )

    response = GQL.execute(
        fgclient.client,
        GQL_GET_VARIABLE;
        variables,
        throw_on_execution_error = true,
    )
    # return response.data["variables"][]

    jstr =
        JSON3.write(response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1])
    return JSON3.read(jstr, DFG.SkeletonDFGVariable)
end

##
function getVariablesSkeleton(fgclient::DFGClient)#, label::Symbol)
    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "fields_summary" => false,
        "fields_full" => false,
    )

    response = GQL.execute(
        fgclient.client,
        GQL_GET_VARIABLES;
        variables,
        throw_on_execution_error = true,
    )

    jstr = JSON3.write(response.data["users"][1]["robots"][1]["sessions"][1]["variables"])
    return JSON3.read(jstr, Vector{DFG.SkeletonDFGVariable})
end

function getVariablesSummary(fgclient::DFGClient)#, label::Symbol)
    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "fields_summary" => true,
        "fields_full" => false,
    )

    T = Vector{
        Dict{
            String, #users
            Vector{Dict{
                String, #robots
                Vector{Dict{
                    String, #sessions
                    Vector{DFG.DFGVariableSummary}, #variables
                }},
            }},
        },
    }

    response = GQL.execute(
        fgclient.client,
        GQL_GET_VARIABLES,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return response.data["users"][1]["robots"][1]["sessions"][1]["variables"]
end

# delete variable and its satelites (by variable id)
function deleteVariable!(fgclient::DFGClient, variable::DFG.AbstractDFGVariable)
    isnothing(variable.id) && error("Variable $(variable.label) does not have an id")
    variables = Dict("variableId" => variable.id)

    response = GQL.execute(
        fgclient.client,
        GQL_DELETE_VARIABLE;
        variables,
        throw_on_execution_error = true,
    )

    return response.data
end

function deleteVariable!(fgclient::DFGClient, label::Symbol)
    
    variables = Dict(
        "userLabel" => fgclient.user.label,
        "robotLabel" => fgclient.robot.label,
        "sessionLabel" => fgclient.session.label,
        "variableLabel" => label,
    )

    response = GQL.execute(
        fgclient.client,
        GQL_DELETE_VARIABLE_BY_LABEL;
        variables,
        throw_on_execution_error = true,
    )

    return response.data
end

## ====================
## Utilities
## ====================

function findVariableNearTimestamp(
    fgclient::DFGClient,
    timestamp::ZonedDateTime,
    window::TimePeriod,
)
    fromtime = timestamp - window
    totime = timestamp + window

    variables = Dict(
        "userLabel" => fgclient.user.label,
        "robotLabel" => fgclient.robot.label,
        "sessionLabel" => fgclient.session.label,
        "fromTime" => fromtime,
        "toTime" => totime,
    )

    response = GQL.execute(
        fgclient.client,
        GQL_FIND_VARIABLES_NEAR_TIMESTAMP;
        variables,
        throw_on_execution_error = true,
    )

    return Symbol.(
        get.(
            response.data["variables"],
            "label",
            missing,
        )
    )
end

# findVariableNearTimestamp(fgclient, ZonedDateTime("2018-08-10T13:06:18.622Z"), Millisecond(100))
