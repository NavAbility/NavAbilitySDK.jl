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
            parent = (Variable=connect,),
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

#TODO delete and update

function deleteBlobEntry!(fgclient::DFGClient, entry::BlobEntry)

    response = GQL.mutate(
        fgclient.client,
        "deleteBlobEntries",
        Dict("where"=>Dict("id"=>entry.id));
        output_fields= ["nodesDeleted", "relationshipsDeleted"],
        throw_on_execution_error = true,
    )

    return response.data["deleteBlobEntries"]
end

# =========================================================================================
# BlobEntry CRUD on other nodes
# =========================================================================================

function DFG.getSessionBlobEntry(fgclient::DFGClient, label::Symbol)
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

function DFG.getSessionBlobEntries(fgclient::DFGClient, startwith::Union{Nothing,String}=nothing)
    client = fgclient.client

    variables = Dict(
        "userLabel" => fgclient.user.label,
        "robotLabel" => fgclient.robot.label,
        "sessionLabel" => fgclient.session.label,
    )
    !isnothing(startwith) && (variables["startwith"]=startwith)

    T = Vector{Dict{String, Vector{Dict{String, Vector{Dict{String, Vector{BlobEntry}}}}}}}

    response = GQL.execute(
        client,
        GQL_GET_SESSION_BLOBENTRIES,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return response.data["users"][1]["robots"][1]["sessions"][1]["blobEntries"]
end


function DFG.getRobotBlobEntry(fgclient::DFGClient, label::Symbol)
    client = fgclient.client

    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "blobLabel" => string(label),
    )

    T = Vector{Dict{String, Vector{Dict{String, Vector{BlobEntry}}}}}

    response = GQL.execute(
        client,
        GQL_GET_ROBOT_BLOBENTRY,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return response.data["users"][1]["robots"][1]["blobEntries"][1]
end

function DFG.getUserBlobEntry(fgclient::DFGClient, label::Symbol)
    client = fgclient.client

    variables = Dict(
        "userId" => fgclient.user.id,
        "blobLabel" => string(label),
    )

    T = Vector{Dict{String, Vector{BlobEntry}}}

    response = GQL.execute(
        client,
        GQL_GET_USER_BLOBENTRY,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return response.data["users"][1]["blobEntries"][1]
end
@enum BlobEntryNodeTypes USER ROBOT SESSION VARIABLE FACTOR

function addNodeBlobEntries!(
    fgclient::DFGClient,
    nodeId::UUID,
    entries::Vector{DFG.BlobEntry},
    nodeType::BlobEntryNodeTypes = VARIABLE,
)
    connect = createConnect(nodeId)

    if nodeType == USER
        parent = (User=connect,)
    elseif nodeType == ROBOT
        parent = (Robot=connect,)
    elseif nodeType == SESSION 
        parent = (Session=connect,)
    elseif nodeType == VARIABLE
        parent = (Variable=connect,)
    elseif nodeType == FACTOR
        parent = (Factor=connect,)
    else
        error("Invalid nodeType")
    end

    userLabel = fgclient.user.label
    robotLabel = nodeType >= ROBOT ? fgclient.robot.label : ""
    sessionLabel = nodeType >= SESSION ? fgclient.session.label : ""
    variableLabel = nodeType == VARIABLE ? error("#TODO get variable label somewhere") : ""
    factorLabel = nodeType == FACTOR ? error("#TODO get factor lable somewhere") : ""

    input = map(entries) do entry
        return BlobEntryCreateInput(;
            parent,
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