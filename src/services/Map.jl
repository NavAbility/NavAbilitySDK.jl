function getMaps(client::GQL.Client, userId::UUID)
    
    variables = Dict(
        "userId" => userId,
    )

    response =
        GQL.execute(client, QUERY_GET_MAPS; variables, throw_on_execution_error = true)

    return response.data["users"][1]["maps"]
end

GQL_LINK_SESSION_TO_MAP = GQL.gql"""
mutation linkSessionMap($mapId: ID!, $sessionId: ID!) {
  updateMaps(
    where: { id: $mapId }
    connect: { sessions: { where: { node: { id: $sessionId } } } }
  ) {
    info {
      nodesCreated
      nodesDeleted
      relationshipsCreated
      relationshipsDeleted
    }
  }
}
"""

# function addMapSession!(map, )

