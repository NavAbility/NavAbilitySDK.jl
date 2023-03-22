# =========================================================================================
# BlobEntry CRUD
# =========================================================================================

function getBlobEntry(fgclient::DFGClient, variableId::UUID, label::Symbol)
    client = fgclient.client

    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableId" => variableId,
        "blobLabel" => string(label),
    )

    response =
        GQL.execute(client, GQL_GET_BLOBENTRY; variables, throw_on_execution_error = true)

    jstr = JSON3.write(
        response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1]["blobEntries"][1],
    )
    return JSON3.read(jstr, DFG.BlobEntry)
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
            (key => getproperty(entry, key) for key in propertynames(entry))...,
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

# =========================================================================================
# BlobEntry CRUD
# =========================================================================================

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
            (key => getproperty(entry, key) for key in propertynames(entry))...,
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

#TODO
# addUserBlobEntries!
# addRobotBlobEntries!
# addSessionBlobEntries!
# addFactorBlobEntries!