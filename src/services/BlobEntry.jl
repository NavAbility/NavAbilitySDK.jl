# =========================================================================================
# BlobEntry CRUD
# =========================================================================================

function getBlobEntry(fgclient::DFGClient, variableLabel::Symbol, label::Symbol)
    client = fgclient.client

    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableLabel" => variableLabel,
        "blobLabel" => string(label),
    )

    T = user_robot_session_variable_T(DFG.BlobEntry)

    response = GQL.execute(
        client,
        GQL_GET_BLOBENTRY,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1]["blobEntries"][1]
end

function getBlobEntries(fgclient::DFGClient, variableLabel::Symbol)
    client = fgclient.client

    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableLabel" => variableLabel,
    )

    T = user_robot_session_variable_T(DFG.BlobEntry)

    response = GQL.execute(
        client,
        GQL_GET_BLOBENTRIES,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1]["blobEntries"]
end

function addBlobEntry!(fgclient::DFGClient, variableLabel::Symbol, entry::DFG.BlobEntry)
    return addBlobEntries!(fgclient, variableLabel, [entry])[1]
end

function addBlobEntries!(
    fgclient::DFGClient,
    variableLabel::Symbol,
    entries::Vector{DFG.BlobEntry},
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
    input = map(entries) do entry
        return BlobEntryCreateInput(;
            userLabel = fgclient.user.label,
            robotLabel = fgclient.robot.label,
            sessionLabel = fgclient.session.label,
            variableLabel = string(variableLabel),
            variable = connect,
            getCommonProperties(BlobEntryCreateInput, entry)...,
        )
    end

    response = GQL.execute(
        fgclient.client,
        GQL_ADD_BLOBENTRIES,
        BlobEntryResponse;
        variables = Dict("blobEntries" => input),
        throw_on_execution_error = true,
    )
    return response.data["addBlobEntries"].blobEntries
end

# another way would be like this:
# GQL.mutate(client, "addBlobEntries", Dict("input"=>input), NVA.BlobEntryResponse; output_fields=#TODO, verbose=2)

function listBlobEntries(fgclient::DFGClient, variableLabel::Symbol)
    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableLabel" => variableLabel,
    )

    T = user_robot_session_variable_T(NamedTuple{(:label,), Tuple{Symbol}})

    response = GQL.execute(
        fgclient.client,
        GQL_LIST_BLOBENTRIES,
        T;
        variables,
        throw_on_execution_error = true,
    )
    return last.(
        response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1]["blobEntries"]
    )
end

# =========================================================================================
# BlobEntry CRUD on other nodes
# =========================================================================================

function getSessionBlobEntry(fgclient::DFGClient, label::Symbol)
    client = fgclient.client

    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "blobLabel" => string(label),
    )

    T = Vector{Dict{String, Vector{Dict{String, Vector{Dict{String, Vector{BlobEntry}}}}}}}

    response = GQL.execute(
        client,
        GQL_GET_SESSION_BLOBENTRY,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return response.data["users"][1]["robots"][1]["sessions"][1]["blobEntries"][1]
end

@enum BlobEntryNodeTypes USER ROBOT SESSION VARIABLE FACTOR

function addNodeBlobEntries!(
    fgclient::DFGClient,
    nodeId::UUID,
    entries::Vector{DFG.BlobEntry},
    nodeType::BlobEntryNodeTypes = VARIABLE,
)
    connect = createConnect(nodeId)

    user = nodeType == USER ? connect : nothing
    robot = nodeType == ROBOT ? connect : nothing
    session = nodeType == SESSION ? connect : nothing
    variable = nodeType == VARIABLE ? connect : nothing
    factor = nodeType == FACTOR ? connect : nothing

    userLabel = fgclient.user.label
    robotLabel = nodeType >= ROBOT ? fgclient.robot.label : ""
    sessionLabel = nodeType >= SESSION ? fgclient.session.label : ""
    variableLabel = nodeType == VARIABLE ? error("#TODO get variable label somewhere") : ""
    factorLabel = nodeType == FACTOR ? error("#TODO get factor lable somewhere") : ""

    input = map(entries) do entry
        return BlobEntryCreateInput(;
            user,
            robot,
            session,
            variable,
            factor,
            userLabel,
            robotLabel,
            sessionLabel,
            variableLabel,
            factorLabel,
            getCommonProperties(BlobEntryCreateInput, entry)...,
        )
    end

    response = GQL.execute(
        fgclient.client,
        GQL_ADD_BLOBENTRIES,
        BlobEntryResponse;
        variables = Dict("blobEntries" => input),
        throw_on_execution_error = true,
    )
    return response.data["addBlobEntries"].blobEntries
end

function addUserBlobEntries!(fgclient::DFGClient, entries::Vector{DFG.BlobEntry})
    return addNodeBlobEntries!(fgclient, fgclient.user.id, entries, USER)
end
function addRobotBlobEntries!(fgclient::DFGClient, entries::Vector{DFG.BlobEntry})
    return addNodeBlobEntries!(fgclient, fgclient.robot.id, entries, ROBOT)
end
function addSessionBlobEntries!(fgclient::DFGClient, entries::Vector{DFG.BlobEntry})
    return addNodeBlobEntries!(fgclient, fgclient.session.id, entries, SESSION)
end

function listSessionBlobEntries(fgclient::DFGClient)
    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
    )

    T = Vector{
        Dict{
            String,
            Vector{
                Dict{
                    String,
                    Vector{Dict{String, Vector{NamedTuple{(:label,), Tuple{Symbol}}}}},
                },
            },
        },
    }

    response = GQL.execute(
        fgclient.client,
        GQL_LIST_SESSION_BLOBENTRIES,
        T;
        variables,
        throw_on_execution_error = true,
    )
    return last.(response.data["users"][1]["robots"][1]["sessions"][1]["blobEntries"])
end

#TODO
# addFactorBlobEntries!