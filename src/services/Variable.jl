# =========================================================================================
# PPE CRUD
# =========================================================================================

function getPPE(fgclient::DFGClient, variableId::UUID, solvekey::Symbol = :default)
    client = fgclient.client

    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableId" => variableId,
        "solveKey" => string(solvekey),
    )

    response = GQL.execute(client, GQL_GET_PPE; variables, throw_on_execution_error = true)
    jstr = JSON3.write(
        response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1]["Ppe"][1],
    )
    return JSON3.read(jstr, DFG.MeanMaxPPE)
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
            (key => getproperty(ppe, key) for key in propertynames(ppe))...,
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

# =========================================================================================
# VariableSolverData CRUD
# =========================================================================================

function getVariableSolverData(
    fgclient::DFGClient,
    variableId::UUID,
    solvekey::Symbol = :default,
)
    client = fgclient.client

    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableId" => variableId,
        "solveKey" => string(solvekey),
    )

    response =
        GQL.execute(client, GQL_GET_SOLVERDATA; variables, throw_on_execution_error = true)
    # return response.data["variables"][]

    jstr = JSON3.write(
        response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1]["solverData"][1],
    )
    return JSON3.read(jstr, DFG.PackedVariableNodeData)
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
            (key => getproperty(vnd, key) for key in propertynames(vnd))...,
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

# =======================================================================================
# Variable CRUD
# =======================================================================================

function addVariable!(fgclient::DFGClient, v::PackedVariable)
    client = fgclient.client
    variableLabel = v.label

    # copy from a packed variable
    label = string(v.label)
    variableType = v.variableType
    nstime = v.nstime
    solvable = v.solvable
    tags = string.(v.tags)
    metadata = v.metadata
    timestamp = string(v.timestamp)

    session = createConnect(fgclient.session.id)

    if isempty(v.blobEntries)
        blobEntries = nothing
    else
        blobEntryNodes = map(v.blobEntries) do entry
            Dict(
                "node"=>
                BlobEntryCreateInput(;
                    userLabel = fgclient.user.label,
                    robotLabel = fgclient.robot.label,
                    sessionLabel = fgclient.session.label,
                    variableLabel = string(variableLabel),
                    (key => getproperty(entry, key) for key in propertynames(entry))...,
                    blobId = isnothing(entry.blobId) ? entry.originId : entry.blobId,
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
                    (key => getproperty(sd, key) for key in propertynames(sd))...,
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
                    (key => getproperty(ppe, key) for key in propertynames(ppe))...,
                ),
            )
        end
        ppes = Dict("create" => ppeNodes)
    end

    addvar = VariableCreateInput(;
        label,
        variableType,
        nstime,
        solvable,
        tags,
        metadata,
        timestamp,
        session,
        blobEntries,
        solverData,
        ppes,
        userLabel = fgclient.user.label,
        robotLabel = fgclient.robot.label,
        sessionLabel = fgclient.session.label,
    )

    variables = Dict("variablesToCreate" => [addvar])

    # return JSON3.write(Dict("query" => GQL_ADD_VARIABLES, "variables" => variables))

    response = GQL.execute(
        client,
        GQL_ADD_VARIABLES,
        VariableResponse;
        variables,
        throw_on_execution_error = true,
    )

    return response.data["addVariables"].variables[1]
end

function getVariables(fgclient::DFGClient)
    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "fields_summary" => true,
        "fields_full" => true,
    )

    response = GQL.execute(
        fgclient.client,
        GQL_GET_VARIABLES,
        Vector{PackedVariable};
        variables,
        throw_on_execution_error = true,
    )
    return response.data["variables"][]
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

    response = GQL.execute(
        fgclient.client,
        GQL_GET_VARIABLE;
        # Vector{PackedVariable};
        variables,
        throw_on_execution_error = true,
    )
    # return response.data["variables"][]
    jstr =
        JSON3.write(response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1])
    return JSON3.read(jstr, PackedVariable)
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