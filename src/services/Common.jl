# type builder for JSON3 deserialization of chain of 
# user[] - robot[] - session[] - variable - T[]
function user_robot_session_variable_T(T)
    Vector{
        Dict{
            String,
            Vector{Dict{String, Vector{Dict{String, Vector{Dict{String, Vector{T}}}}}}},
        },
    }
end

function createConnect(id::UUID)
    return Dict("connect" => Dict("where" => Dict("node" => Dict("id" => string(id)))))
end

function createVariableConnect(
    userLabel::String,
    robotLabel::String,
    sessionLabel::String,
    label::Symbol,
)
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
function getCommonProperties(::Type{T}, from::F) where {T, F}
    commonfields = intersect(fieldnames(T), fieldnames(F))
    return (k => getproperty(from, k) for k in commonfields)
end
