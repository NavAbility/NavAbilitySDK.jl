"""
Gets the User/Robot/Session nodes from the database.
"""
function Context(
    client::GQL.Client,
    userLabel::String,
    robotLabel::String,
    sessionLabel::String;
    addRobotIfNotExists::Bool = false,
    addSessionIfNotExists::Bool = false,
)
    variables = Dict(
        "userLabel" => userLabel,
        "robotLabel" => robotLabel,
        "sessionLabel" => sessionLabel,
    )

    response = GQL.execute(
        client,
        GQL_GET_USERROBOTSESSION,
        Vector{User};
        variables,
        throw_on_execution_error = true,
    )

    # response.errors !== nothing && error(response.errors)

    isempty(response.data["users"]) && error("User $(userLabel) does not exist")
    user = response.data["users"][1]

    robot = if length(user.robots) > 0
        user.robots[1]
    elseif addRobotIfNotExists
        addRobot(client, user, robotLabel)
    else
        error("Robot $(robotLabel) does not exist")
    end

    session = if length(robot.sessions) > 0
        robot.sessions[1]
    elseif addSessionIfNotExists
        addSession(client, user, robot, sessionLabel)
    else
        error("Session '$(sessionLabel)' does not exist")
    end

    return Context(user, robot, session)
end

function User(client::GQL.Client, userLabel::String)
    variables = Dict("userLabel" => userLabel)
    response = GQL.execute(
        client,
        NvaSDK.GQL_GET_USER,
        Vector{NvaSDK.User};
        variables,
        throw_on_execution_error = true,
    )
    return response.data["users"][]
end

function addSession(client::GQL.Client, user::User, robot::Robot, sessionLabel::String)
    variables = Dict(
        "robotId" => robot.id,
        "robotLabel" => robot.label,
        "userLabel" => user.label,
        "version" => DFG._getDFGVersion(), #TODO jl1.9 pkgversion
        "sessionLabel" => sessionLabel,
    )
    response = GQL.execute(
        client,
        GQL_ADD_SESSION,
        SessionResponse;
        variables,
        throw_on_execution_error = true,
    )

    @debug response

    length(response.data["addSessions"].sessions) != 1 &&
        error("Failed when creating session.\n", response)

    return response.data["addSessions"].sessions[1]
end

function addRobot(client::GQL.Client, user::User, robotLabel::String)
    variables = Dict(
        "userId" => user.id,
        "uniqueKey" => "$(user.id).$(robotLabel)",
        "version" => DFG._getDFGVersion(),
        "robotLabel" => robotLabel,
        "userLabel" => user.label,
    )
    response = GQL.execute(
        client,
        GQL_ADD_ROBOT,
        RobotResponse;
        variables,
        throw_on_execution_error = true,
    )

    return response.data["addRobots"].robots[1]
end

# =========================================================================================
# Meta Data
# =========================================================================================
# get and set!

function getRobotMeta(fgclient::DFGClient)
    gql = """
      {
        users(where: { id: "$(fgclient.user.id)" }) {
          robots(where: { id: "$(fgclient.robot.id)" }) {
            metadata
          }
        }
      }
      """
    response = GQL.execute(fgclient.client, gql; throw_on_execution_error = true)

    return JSON3.read(
        base64decode(response.data["users"][1]["robots"][1]["metadata"]),
        Dict{Symbol, DFG.SmallDataTypes},
    )
end

function setRobotMeta!(fgclient::DFGClient, smallData::Dict{Symbol, DFG.SmallDataTypes})
    meta = base64encode(JSON3.write(smallData))

    gql = """
    mutation {
      updateRobots(
        where: { id: "$(fgclient.robot.id)" }
        update: { metadata: "$(meta)" }
      ) {
        robots {
          metadata
        }
      }
    }
    """
    response = GQL.execute(fgclient.client, gql; throw_on_execution_error = true)

    return JSON3.read(
        base64decode(response.data["updateRobots"]["robots"][1]["metadata"]),
        Dict{Symbol, DFG.SmallDataTypes},
    )
end