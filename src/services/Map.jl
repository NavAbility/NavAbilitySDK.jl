function getMaps(client::GQL.Client, userId::UUID)
    variables = Dict("userId" => userId)

    T = Vector{Dict{String, Vector{Map}}}

    response =
        GQL.execute(client, QUERY_GET_MAPS, T; variables, throw_on_execution_error = true)

    return response.data["users"][1]["maps"]
end

function getMaps(client::GQL.Client)

    T = Vector{Map}

    response =
        GQL.execute(client, QUERY_GET_MAPS_ALL, T; throw_on_execution_error = true)

    return response.data["maps"]
end

function getMap(client::GQL.Client, mapId::UUID)
    variables = Dict("mapId" => mapId)

    T = Vector{Map}

    response =
        GQL.execute(client, QUERY_GET_MAP, T; variables, throw_on_execution_error = true)

    return response.data["maps"][1]
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

function addMap!(client::GQL.Client, mapLabel::String; status = "", description = "")
  variables = Dict(
      "label" => mapLabel,
      "status" => status,
      "description" => description,
  )
  response = GQL.execute(
      client,
      GQL_ADD_MAP;
      # T;
      variables,
      throw_on_execution_error = true,
  )
  return response.data["addMaps"]["maps"][1]
end

function addSession!(client::GQL.Client, mapId, sessionId)
  variables = Dict("mapId" => mapId, "sessionId" => sessionId)

  response =
      GQL.execute(client, GQL_LINK_SESSION_TO_MAP; variables, throw_on_execution_error = true)

  return response.data["updateMaps"]["info"]
end

function getSession!(client::GQL.Client, mapId)
  variables = Dict("mapId" => mapId)

  T = Vector{Map}

  response =
      GQL.execute(client, QUERY_GET_MAP, T; variables, throw_on_execution_error = true)

  return response.data["maps"][1]
end