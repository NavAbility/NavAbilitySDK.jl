QUERY_GET_FACTORGRAPH = """
query QUERY_GET_FACTORGRAPH(\$fgId: ID!) {
  factorgraphs (where: {id: \$fgId}) {
    label
    createdTimestamp
    namespace
  }
}
"""

function getGraph(client::NavAbilityClient, label::Symbol)
    fgId = getId(client.id, label)
    variables = Dict("fgId" => fgId)

    T = Vector{NvaNode{Factorgraph}}

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
    $metadata: String = "",
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

function addGraph!(client::NavAbilityClient, label::Symbol)
    @assert isValidLabel(label) "Factor graph label ($Label) is not a valid label"

    variables = Dict(
        "orgId" => client.id,
        "id" => getId(client.id, label),
        "label" => label,
        "_version" => DFG._getDFGVersion(),
    )

    # FactorGraphRemoteResponse
    T = @NamedTuple{factorgraphs::Vector{NvaNode{Factorgraph}}}

    response =
        GQL.execute(client.client, GQL_ADD_FACTORGRAPH, T; variables, throw_on_execution_error = true)

    return handleMutate(response, "addFactorgraphs", :factorgraphs)[1]
end

GQL_DELETE_FG = GQL.gql"""
mutation deleteFG($id: ID!) {
  deleteFactorgraph(
    where: { id: $id }
    delete: {
      blobEntries: {
        where: { node: { parentConnection: {Factorgraph: {node: {id: $id } } } } }
      }
    }
  ) {
    nodesDeleted
    relationshipsDeleted
  }
}
"""

function deleteGraph!(fgclient::NavAbilityDFG)
    
    id = getId(fgclient.fg)
    variables = Dict("id" => id)

    nvars = length(listVariables(fgclient))
    nvars > 0 && error(
        "Only empty sessions can be deleted, $(fgclient.session.label) still has $nvars variables.",
    )

    nfacts = length(listFactors(fgclient))
    nfacts > 0 && error(
        "Only empty sessions can be deleted, $(fgclient.session.label) still has $nfacts factors.",
    )

    variables = Dict("sessionId" => fgclient.session.id)

    fgId = getId(client.id, label)
    variables = Dict("fgId" => fgId)

    response = GQL.execute(
        fgclient.client.client,
        GQL_DELETE_FG;
        variables,
        throw_on_execution_error = true,
    )

    return response.data
end

QUERY_LIST_FACTORGRAPHS = GQL.gql"""
query listGraphs($id: ID!) {
    orgs(where: {id: $id}) {
        fgs {
            label
        }
    }
}
"""

function listGraphs(client::NavAbilityClient)

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

#TODO update to standard pattern
function DFG.getGraphMetadata(fgclient::NavAbilityDFG)
    gql = """
    {
        factorgraphs(where: {id: "$(getId(fgclient.fg))"}) {
            metadata
        }
    }
    """
    response = GQL.execute(fgclient.client.client, gql; throw_on_execution_error = true)
    b64data = response.data["factorgraphs"][1]["metadata"]

    if isnothing(b64data) || b64data == ""
        return Dict{Symbol, DFG.SmallDataTypes}()
    else
        return JSON3.read(
            base64decode(b64data),
            Dict{Symbol, DFG.SmallDataTypes},
        )
    end
end

function DFG.setGraphMetadata!(fgclient::NavAbilityDFG, smallData::Dict{Symbol, DFG.SmallDataTypes})
    meta = base64encode(JSON3.write(smallData))

    gql = """
    mutation {
      updateFactorgraphs(
        where: { id: "$(getId(fgclient.fg))" }
        update: { metadata: "$(meta)" }
      ) {
        factorgraphs {
          metadata
        }
      }
    }
    """
    response = GQL.execute(fgclient.client.client, gql; throw_on_execution_error = true)

    return JSON3.read(
        base64decode(response.data["updateFactorgraphs"]["factorgraphs"][1]["metadata"]),
        Dict{Symbol, DFG.SmallDataTypes},
    )
end


## =======================================================================================
## Connect Factorgraph to other nodes
## =======================================================================================


GQL_CONNECT_GRAPH_TO_MODEL = GQL.gql"""
mutation connectGraphModel($modelId: ID!, $fgId: ID!) {
  updateModels(
    where: { id: $modelId }
    update: { fgs: { connect: { where: { node: { id: $fgId } } } } }
  ) {
    info {
      relationshipsCreated
    }
  }
}
"""

function connect!(client, model::NvaNode{Model}, fg::NvaNode{Factorgraph})
    variables = Dict("modelId" => getId(model), "fgId" => getId(fg))

    response = executeGql(client, GQL_CONNECT_GRAPH_TO_MODEL, variables)

    return response.data["updateModels"]["info"]["relationshipsCreated"]
end


GQL_CONNECT_GRAPH_TO_AGENT = GQL.gql"""
mutation connectGraphModel($agentId: ID!, $fgId: ID!) {
  updateAgents(
    where: { id: $agentId }
    update: { fgs: { connect: { where: { node: { id: $fgId } } } } }
  ) {
    info {
      relationshipsCreated
    }
  }
}
"""

function connect!(client, agent::NvaNode{Agent}, fg::NvaNode{Factorgraph})
    variables = Dict("agentId" => getId(agent), "fgId" => getId(fg))

    response = executeGql(client, GQL_CONNECT_GRAPH_TO_AGENT, variables)

    return response.data["updateAgents"]["info"]["relationshipsCreated"]
end


QUERY_GET_GRAPHS_AGENTS = GQL.gql"""
query getAgents_Graph($id: ID!) {
  factorgraphs(where: {id: $id}) {
    agents {
      label
      namespace
    }
  }
}
"""

function getAgents(client::NavAbilityClient, fg::NvaNode{Factorgraph})
    response = executeGql(
        client,
        QUERY_GET_GRAPHS_AGENTS,
        Dict("id" => getId(fg)),
        Vector{Dict{Symbol, Vector{NvaNode{Agent}}}},
    )
    return handleQuery(response, "factorgraphs")[1][:agents]
end