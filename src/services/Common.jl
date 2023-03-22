
function createConnect(id::UUID)
    return Dict("connect" => Dict("where" => Dict("node" => Dict("id" => string(id)))))
end

function createVariableConnect(userLabel::String, robotLabel::String, sessionLabel::String, label::Symbol)
    return Dict(
        "connect" => Dict(
            "where" => Dict(
                "node" => Dict(
                    "label" => string(label),
                    "sessionLabel" => string(sessionLabel),
                    "robotLabel" => string(robotLabel),
                    "userLabel" => string(userLabel),
                ),
            ),
        ),
    )
    # variable": {"connect": { "where": {"node": {"label": "x0", "robotLabel": "IntegrationRobot", "userLabel": 
end
# exists(client, context, label::Symbol) = 
