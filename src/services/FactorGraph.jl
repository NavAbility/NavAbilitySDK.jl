
function listVariableNeighbors(fgclient::DFGClient, variableLabel::Symbol)
    variables = Dict(
        "userLabel" => fgclient.user.label,
        "robotLabel" => fgclient.robot.label,
        "sessionLabel" => fgclient.session.label,
        "variableLabel" => variableLabel,
    )

    T = Vector{Dict{String, Vector{NamedTuple{(:label,), Tuple{Symbol}}}}}

    response = GQL.execute(
        fgclient.client,
        GQL_LIST_VARIABLE_NEIGHBORS,
        T;
        variables,
        throw_on_execution_error = true,
    )
    return last.(response.data["variables"][1]["factors"])
end

function listFactorNeighbors(fgclient::DFGClient, factorLabel::Symbol)
    variables = Dict(
        "userLabel" => fgclient.user.label,
        "robotLabel" => fgclient.robot.label,
        "sessionLabel" => fgclient.session.label,
        "factorLabel" => factorLabel,
    )

    T = Vector{Dict{String, Vector{NamedTuple{(:label,), Tuple{Symbol}}}}}

    response = GQL.execute(
        fgclient.client,
        GQL_LIST_FACTOR_NEIGHBORS,
        T;
        variables,
        throw_on_execution_error = true,
    )
    return last.(response.data["factors"][1]["variables"])
end

#TODO should getNeighbors be listNeighbors
DFG.getNeighbors(fgclient::DFGClient, nodeLabel::Symbol) = listNeighbors(fgclient, nodeLabel)

function listNeighbors(fgclient::DFGClient, nodeLabel::Symbol)
    variables = Dict(
        "userLabel" => fgclient.user.label,
        "robotLabel" => fgclient.robot.label,
        "sessionLabel" => fgclient.session.label,
        "nodeLabel" => nodeLabel,
    )

    T = Vector{Dict{String, Vector{NamedTuple{(:label,), Tuple{Symbol}}}}}

    response = GQL.execute(
        fgclient.client,
        GQL_LIST_NEIGHBORS,
        T;
        variables,
        throw_on_execution_error = true,
    )
    flbls =
        isempty(response.data["variables"]) ? Symbol[] :
        last.(response.data["variables"][1]["factors"])
    vlbls =
        isempty(response.data["factors"]) ? Symbol[] :
        last.(response.data["factors"][1]["variables"])

    return union(flbls, vlbls)
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