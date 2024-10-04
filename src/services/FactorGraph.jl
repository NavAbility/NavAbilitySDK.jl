QUERY_GET_FACTORGRAPH = """
query QUERY_GET_FACTORGRAPH(\$fgId: ID!) {
  factorgraphs (where: {id: \$fgId}) {
    label
    createdTimestamp
    namespace
  }
}
"""


function getFg(client::NavAbilityClient, label::Symbol)
    fgId = getId(client.id, label)
    variables = Dict("fgId" => fgId)

    T = Vector{NvaFactorGraph}

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
mutation addFactorGraph(
    $orgId: ID = ""
    $id: ID = "",
    $label: String = "",
    $description: String = "",
    $metadata: Metadata = "",
    $_version: String = "",
) {
  addFactorgraphs(
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

function addFg!(client::NavAbilityClient, label::Symbol)
    variables = Dict(
        "orgId" => client.id,
        "id" => getId(client.id, label),
        "label" => label,
        "_version" => DFG._getDFGVersion(),
    )

    # FactorGraphRemoteResponse
    T = @NamedTuple{factorgraphs::Vector{NvaFactorGraph}}

    response =
        GQL.execute(client.client, GQL_ADD_FACTORGRAPH, T; variables, throw_on_execution_error = true)

    return handleMutate(response, "addFactorgraphs", :factorgraphs)[1]
end

QUERY_LIST_FACTORGRAPHS = GQL.gql"""
query listFgs($id: ID!) {
    orgs(where: {id: $id}) {
        fgs {
            label
        }
    }
}
"""

function listFgs(client::NavAbilityClient)

    T = Vector{Dict{String, Vector{@NamedTuple{label::Symbol}}}}

    response = GQL.execute(
            client.client,
            QUERY_LIST_FACTORGRAPHS,
            T;
            variables = (id=client.id,),
            throw_on_execution_error = true,
    )

    return last.(handleQuery(response, "orgs", Symbol(client.id))["fgs"])
end

function DFG.listNeighbors(fgclient::NavAbilityDFG, label::Symbol)
    variables = (id=getId(fgclient.fg, label),)

    T = Vector{Dict{String, Vector{NamedTuple{(:label,), Tuple{Symbol}}}}}

    response = GQL.execute(
        fgclient.client.client,
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

function exists(fgclient::NavAbilityDFG, label::Symbol)
    variables = (id=getId(fgclient.fg, label),)

    response = GQL.execute(
        fgclient.client.client,
        GQL_EXISTS_VARIABLE_FACTOR_LABEL;
        variables,
        throw_on_execution_error = true,
    )

    hasvar = !isempty(response.data["variables"])
    hasfac = !isempty(response.data["factors"])

    return hasvar || hasfac
end