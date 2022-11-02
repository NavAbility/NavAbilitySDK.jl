
function getExportSessionBlobId(client::NavAbilityClient, eventId::AbstractString)
    response = client.query(QueryOptions(
        "events_by_id",
        GQL_GET_EXPORT_SESSION_COMPLETE_EVENT_BY_ID,
        Dict("eventId" => eventId)
    )) |> fetch
    payload = JSON.parse(response.Data)
    blobId = payload["data"]["events"][1]["data"]["blob"]["id"]
    return blobId
end

function exportSessionEvent(
    client::NavAbilityClient,
    session::ExportSessionInput;
    options = nothing
  )
  #
  payload = Dict{String, Any}(
      "session" => session,
  )
  if (!isnothing(options))
      payload["options"] = options
  end
  response = client.mutate(MutationOptions(
      "sdk_export_session",
      MUTATION_EXPORT_SESSION,
      payload
  )) |> fetch
  rootData = JSON.parse(response.Data)
  if haskey(rootData, "errors")
      throw("Error: $(rootData["errors"])")
  end
  data = get(rootData,"data",nothing)
  if data === nothing return "Error" end

  # return the eventId
  return data["exportSession"]["context"]["eventId"]
end

exportSession( client::NavAbilityClient, session::ExportSessionInput; options = nothing) = @async exportSessionEvent(client,session; options)

function exportSession(
        client::NavAbilityClient, 
        context::Client, 
        filename::AbstractString; options=nothing
    )
    #
    expSessInp = ExportSessionInput(;
        id = SessionId(;
            key = SessionKey(
            userId = context.userId,
            robotId = context.robotId,
            sessionId = context.sessionId
            )
        ),
        filename
    )

    exportSession(client, expSessInp; options)
end



#