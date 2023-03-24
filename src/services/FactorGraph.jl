
function getNeighbors(fgclient::DFGClient, v::PackedVariable)
    #TODO fallback to using the label
    isnothing(v.id) && error("No id field in variable")

    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "variableId" => v.id,
    )

    T = Vector{
        Dict{
            String,
            Vector{
                Dict{
                    String,
                    Vector{
                        Dict{
                            String,
                            Vector{
                                Dict{String, Vector{NamedTuple{(:label,), Tuple{Symbol}}}},
                            },
                        },
                    },
                },
            },
        },
    }

    response = GQL.execute(
        fgclient.client,
        GQL_LIST_VARIABLE_NEIGHBORS,
        T;
        variables,
        throw_on_execution_error = true,
    )
    return last.(
        response.data["users"][1]["robots"][1]["sessions"][1]["variables"][1]["factors"]
    )
end

function getNeighbors(fgclient::DFGClient, f::PackedFactor)
    #TODO fallback to using the label
    isnothing(f.id) && error("No id field in factor")

    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "factorId" => f.id,
    )

    T = Vector{
        Dict{
            String,
            Vector{
                Dict{
                    String,
                    Vector{
                        Dict{
                            String,
                            Vector{
                                Dict{String, Vector{NamedTuple{(:label,), Tuple{Symbol}}}},
                            },
                        },
                    },
                },
            },
        },
    }

    response = GQL.execute(
        fgclient.client,
        GQL_LIST_FACTOR_NEIGHBORS,
        T;
        variables,
        throw_on_execution_error = true,
    )
    return last.(
        response.data["users"][1]["robots"][1]["sessions"][1]["factors"][1]["variables"]
    )
end

function exists(fgclient::DFGClient, label::Symbol)
    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "label" => label,
    )

    response = GQL.execute(
        fgclient.client,
        GQL_EXISTS_VARIABLE_FACTOR_LABEL;
        variables,
        throw_on_execution_error = true,
    )

    hasvar = !isempty(response.data["users"][1]["robots"][1]["sessions"][1]["variables"])
    hasfac = !isempty(response.data["users"][1]["robots"][1]["sessions"][1]["factors"])

    return hasvar || hasfac
end