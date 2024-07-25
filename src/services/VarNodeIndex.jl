GQL_ADD_VARIABLE_INDEX_NODE = GQL.gql"""
mutation addVariableIndexNode(
    $id: ID!,
    $variables: VariableIndexNodeVariablesFieldInput!
){
  addVariableIndexNodes(
    input: {
        id: $id, 
        variables: $variables
    }
  ) {
    variableIndexNodes {
      id
    }
    info {
      nodesCreated
      relationshipsCreated
    }
  }
}
"""

GQL_ADD_VARIABLE_INDEX_NODE_ONLY = GQL.gql"""
mutation addVariableIndexNode(
    $id: ID!,
){
  addVariableIndexNodes(
    input: {
        id: $id, 
    }
  ) {
    variableIndexNodes {
      id
    }
    info {
      nodesCreated
      relationshipsCreated
    }
  }
}
"""

GQL_ADD_EDGE_VARIABLE_INDEX_NODE = GQL.gql"""
mutation addEdgeVariableIndexNode(
    $id: ID!,
    $weight: Float!,
    $node: VariableWhere!
){
    updateVariableIndexNodes(
          where: {id: $id},
          connect: {variables: {edge: {weight: $weight}, where: {node: $node}}}
        ) {
        info {
            relationshipsCreated
        }
    }
}
"""

function createConnectionsVariableWeight(fg, edges::Vector{Tuple{Symbol, Float64}})

    function createEdge(e::Tuple{Symbol, Float64}) 
        Dict(
            "edge" => (weight = e[2],),
            "where" => Dict(
                "node" => (
                    label = e[1],
                    userLabel = fg.user.label,
                    robotLabel = fg.robot.label,
                    sessionLabel = fg.session.label,
                )
            ),
        )
    end

    return Dict(
        "connect" => map(createEdge, edges),
    )
    return connect
end

function addEdge_VariableIndexNode(fg, id, label::Symbol, weight::Float64)

    variables = Dict(
        "node" => Dict(
            "label" => label,
            "userLabel" => fg.user.label,
            "robotLabel" => fg.robot.label,
            "sessionLabel" => fg.session.label,
        ),
        "weight" => weight,
        "id" => string(fg.session.id, "/", id)
    )
    response = GQL.execute(
        fg.client,
        GQL_ADD_EDGE_VARIABLE_INDEX_NODE;
        variables,
        throw_on_execution_error = true,
    )
    return response
end

function addVariableIndexNode!(fg::DFGClient, id::Int, edges::Vector{Tuple{Symbol, Float64}})
    variables = Dict(
        "id" => string(fg.session.id, "/", id),
        "variables" => createConnectionsVariableWeight(fg, edges),
    )
    response = GQL.execute(
        fg.client,
        GQL_ADD_VARIABLE_INDEX_NODE;
        variables,
        throw_on_execution_error = true,
    )
    return response.data["addVariableIndexNodes"]["variableIndexNodes"][1]
end

function addVariableIndexNode!(fg::DFGClient, id::Int)
    variables = Dict(
        "id" => string(fg.session.id, "/", id),
    )
    response = GQL.execute(
        fg.client,
        GQL_ADD_VARIABLE_INDEX_NODE_ONLY;
        variables,
        throw_on_execution_error = true,
    )
    return response.data["addVariableIndexNodes"]["variableIndexNodes"][1]
end