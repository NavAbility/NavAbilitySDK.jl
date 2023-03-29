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

    return response.data
end

function deleteVariableSolverData!(fgclient::DFGClient, variableLabel::Symbol, solveKey::Symbol)
    variables = Dict(
        "userLabel" => fgclient.user.label,
        "robotLabel" => fgclient.robot.label,
        "sessionLabel" => fgclient.session.label,
        "variableLabel" => variableLabel,
        "solveKey" => solveKey,
    )
    response = GQL.execute(
        fgclient.client,
        GQL_DELETE_SOLVERDATA_BY_LABEL;
        variables,
        throw_on_execution_error = true,
    )

    return response.data
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