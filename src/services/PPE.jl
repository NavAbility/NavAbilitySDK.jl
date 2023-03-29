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
