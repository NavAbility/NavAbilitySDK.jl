QUERY_GET_FACTORGRAPH = """
query QUERY_GET_FACTORGRAPH(\$fgId: ID!) {
  factorgraphs (where: {id: \$fgId}) {
    label
    createdTimestamp
    namespace
  }
}
"""


function getFactorGraph(client::NavAbilityClient, label::Symbol)
    fgId = getId(client.id, label)
    variables = Dict("fgId" => fgId)

    T = Vector{FactorGraphRemote}

    response = GQL.execute(
        client.client,
        QUERY_GET_FACTORGRAPH,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return handleQuery(response, "factorgraphs", label)

end

GQL_ADD_FACTORGRAPH = GQL.gql"""
mutation createFactorGraph(
    $orgId: ID = ""
    $id: ID = "",
    $label: String = "",
    $description: String = "",
    $metadata: Metadata = "",
    $_version: String = "",
) {
  createFactorgraphs(
    input: {id: $id, label: $label, _version: $_version, description: $description, metadata: $metadata, org: {connect: {where: {node: {id: $orgId}}}}}
  ) {
    factorgraphs {
        label
        createdTimestamp
        namespace
    }
  }
}
"""

function addFactorGraph!(client::NavAbilityClient, label::Symbol)
    variables = Dict(
        "orgId" => client.id,
        "id" => getId(client.id, label),
        "label" => label,
        "_version" => DFG._getDFGVersion(),
    )

    # FactorGraphRemoteResponse
    T = @NamedTuple{factorgraphs::Vector{FactorGraphRemote}}

    response =
        GQL.execute(client.client, GQL_ADD_FACTORGRAPH, T; variables, throw_on_execution_error = true)

    return handleMutate(response, "createFactorgraphs", :factorgraphs)
end

# ===================================================================

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
function DFG.getNeighbors(fgclient::DFGClient, nodeLabel::Symbol)
    listNeighbors(fgclient, nodeLabel)
end

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