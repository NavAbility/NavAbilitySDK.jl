# =========================================================================================
# PPE CRUD
# =========================================================================================

function getPPE(fgclient::DFGClient, variableLabel::Symbol, solvekey::Symbol = :default)
    client = fgclient.client

    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableLabel" => variableLabel,
        "solveKey" => string(solvekey),
    )

    T = user_robot_session_variable_T(DFG.MeanMaxPPE)

    response =
        GQL.execute(client, GQL_GET_PPE, T; variables, throw_on_execution_error = true)

    return response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1]["ppes"][1]
end

function getPPEs(fgclient::DFGClient, variableLabel::Symbol)
    client = fgclient.client

    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableLabel" => variableLabel,
    )

    T = user_robot_session_variable_T(DFG.MeanMaxPPE)

    response =
        GQL.execute(client, GQL_GET_PPES, T; variables, throw_on_execution_error = true)

    return response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1]["ppes"]
end

function addPPE!(fgclient::DFGClient, variableLabel::Symbol, ppe::DFG.MeanMaxPPE)
    addPPEs!(fgclient, variableLabel, [ppe])
end

function addPPEs!(fgclient::DFGClient, variableLabel::Symbol, ppes::Vector{DFG.MeanMaxPPE})

    # if (variable.id === nothing)
    #     error("Variable does not have an ID. Has it been created on the server?")
    # end

    connect = createVariableConnect(
        fgclient.user.label,
        fgclient.robot.label,
        fgclient.session.label,
        variableLabel,
    )

    # TODO we can probably standardise this
    ppeinput = map(ppes) do ppe
        return PPECreateInput(;
            userLabel = fgclient.user.label,
            robotLabel = fgclient.robot.label,
            sessionLabel = fgclient.session.label,
            variableLabel = string(variableLabel),
            variable = connect,
            getCommonProperties(PPECreateInput, ppe)...,
        )
    end

    response = GQL.execute(
        fgclient.client,
        GQL_ADD_PPES,
        PPEResponse;
        variables = Dict("ppes" => ppeinput),
        throw_on_execution_error = true,
    )

    return response.data["addPpes"].ppes
end

function PPEUpdateInputDict(ppe::MeanMaxPPE)
    #Mutable intermediate serialization object
    request = JSON3.read(JSON3.write(ppe), Dict{String, Any})
    delete!(request, "createdTimestamp")
    delete!(request, "lastUpdatedTimestamp")
    return request
end

function updatePPE!(fgclient::DFGClient, ppe::MeanMaxPPE)
    isnothing(ppe.id) &&
        error("Field id is needed for update, please use add, #TODO fallback to add")

    request = Dict(getCommonProperties(PPECreateInput, ppe))
    # Make request
    response = GQL.execute(
        fgclient.client,
        GQL_UPDATE_PPE,
        PPEResponse;
        variables = Dict("ppe" => request, "id" => ppe.id),
        throw_on_execution_error = true,
    )
    # Assuming one update, error if not
    numUpdated = length(response.data["updatePpes"].ppes)
    numUpdated != 1 && error("Expected to update one PPE but updated $(numUpdated)")
    return response.data["updatePpes"].ppes[1]
end

function deletePPE!(fgclient::DFGClient, ppe::DFG.MeanMaxPPE)
    variables = Dict("id" => ppe.id)

    response = GQL.execute(
        fgclient.client,
        GQL_DELETE_PPE;
        variables,
        throw_on_execution_error = true,
    )

    return response
end

function listPPEs(fgclient::DFGClient, variableLabel::Symbol)
    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableLabel" => variableLabel,
    )

    T = user_robot_session_variable_T(NamedTuple{(:solveKey,), Tuple{Symbol}})

    response = GQL.execute(
        fgclient.client,
        GQL_LIST_PPES,
        T;
        variables,
        throw_on_execution_error = true,
    )
    return last.(
        response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1]["ppes"]
    )
end

# =========================================================================================
# VariableSolverData CRUD
# =========================================================================================

function getVariableSolverData(
    fgclient::DFGClient,
    variableLabel::Symbol,
    solveKey::Symbol = :default,
)
    client = fgclient.client

    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableLabel" => variableLabel,
        "solveKey" => string(solveKey),
    )

    T = user_robot_session_variable_T(DFG.PackedVariableNodeData)

    response = GQL.execute(
        client,
        GQL_GET_SOLVERDATA,
        T;
        variables,
        throw_on_execution_error = true,
    )

    solverdata =
        response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1]["solverData"]
    isempty(solverdata) && throw(KeyError(solveKey))
    return solverdata[]
end

function getVariableSolverDataAll(fgclient::DFGClient, variableLabel::Symbol)
    client = fgclient.client

    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableLabel" => variableLabel,
    )

    T = user_robot_session_variable_T(DFG.PackedVariableNodeData)

    response = GQL.execute(
        client,
        GQL_GET_SOLVERDATA_ALL,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1]["solverData"]
end

function addVariableSolverData!(
    fgclient::DFGClient,
    variableLabel::Symbol,
    vnd::DFG.PackedVariableNodeData,
)
    addVariableSolverData!(fgclient, variableLabel, [vnd])
end

function addVariableSolverData!(
    fgclient::DFGClient,
    variableLabel::Symbol,
    vnds::Vector{DFG.PackedVariableNodeData},
)

    # if (variable.id === nothing)
    #     error("Variable does not have an ID. Has it been created on the server?")
    # end

    connect = createVariableConnect(
        fgclient.user.label,
        fgclient.robot.label,
        fgclient.session.label,
        variableLabel,
    )

    # TODO we can probably standardise this
    input = map(vnds) do vnd
        return SolverDataCreateInput(;
            userLabel = fgclient.user.label,
            robotLabel = fgclient.robot.label,
            sessionLabel = fgclient.session.label,
            variableLabel = string(variableLabel),
            variable = connect,
            getCommonProperties(SolverDataCreateInput, vnd)...,
        )
    end

    response = GQL.execute(
        fgclient.client,
        GQL_ADD_SOLVERDATA,
        SolverDataResponse;
        variables = Dict("solverData" => input),
        throw_on_execution_error = true,
    )

    return response.data["addSolverData"].solverData
end

function updateVariableSolverData!(fgclient::DFGClient, vnd::DFG.PackedVariableNodeData)
    isnothing(vnd.id) &&
        error("Field id is needed for update, please use add, #TODO fallback to add")

    request = Dict(getCommonProperties(PPECreateInput, ppe))
    # Make request
    response = GQL.execute(
        fgclient.client,
        GQL_UPDATE_SOLVERDATA,
        SolverDataResponse;
        variables = Dict("solverData" => request, "id" => vnd.id),
        throw_on_execution_error = true,
    )
    # Assuming one update, error if not
    numUpdated = length(response.data["updateSolverData"].solverData)
    numUpdated != 1 && error("Expected to update one SolverData but updated $(numUpdated)")
    return response.data["updateSolverData"].solverData[1]
end

function deleteVariableSolverData!(fgclient::DFGClient, vnd::DFG.PackedVariableNodeData)
    variables = Dict("id" => vnd.id)

    response = GQL.execute(
        fgclient.client,
        GQL_DELETE_SOLVERDATA;
        variables,
        throw_on_execution_error = true,
    )

    return response
end

function listVariableSolverData(fgclient::DFGClient, variableLabel::Symbol)
    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableLabel" => variableLabel,
    )

    T = user_robot_session_variable_T(NamedTuple{(:solveKey,), Tuple{Symbol}})

    response = GQL.execute(
        fgclient.client,
        GQL_LIST_SOLVERDATA,
        T;
        variables,
        throw_on_execution_error = true,
    )
    return last.(
        response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1]["solverData"]
    )
end

# =======================================================================================
# Variable CRUD
# =======================================================================================

function VariableCreateInput(fgclient::DFGClient, v::PackedVariable)
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

function addVariable!(fgclient::DFGClient, v::PackedVariable)
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

function addVariables!(fgclient::DFGClient, vars::Vector{PackedVariable})
    #
    addvars = VariableCreateInput.(fgclient, vars)

    # Chunk it at around 100 per call
    chunks = Iterators.partition(addvars, 20)
    length(chunks) > 1 && @info "Adding variables in $(length(chunks)) batches"

    newVarReturns = PackedVariable[]
    p = Progress(length(chunks))
    for c in chunks
        ProgressMeter.next!(p; showvalues = [("adding","$(c[1].label)...$(c[end].label)")])

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
        Dict{String, Vector{Dict{String, Vector{Dict{String, Vector{PackedVariable}}}}}},
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

#TODO consider this to be getVariableFull, that way 
# - getVariable(...)::DFGVariable
# - getVariableFull(...)::PackedVariable (to rename to Variable)
# - getVariableSummary(...)::DFGVariableSummary
# - getVariableSkeleton(...)::SkeletonDFGVariable (maybe fix inconsistent naming here)
function getVariable(fgclient::DFGClient, label::Symbol)
    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableLabel" => string(label),
        "fields_summary" => true,
        "fields_full" => true,
    )

    T = Vector{
        Dict{String, Vector{Dict{String, Vector{Dict{String, Vector{PackedVariable}}}}}},
    }

    response = GQL.execute(
        fgclient.client,
        GQL_GET_VARIABLE,
        T;
        variables,
        throw_on_execution_error = true,
    )
    return response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1]
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
    # return response.data["variables"][]

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
