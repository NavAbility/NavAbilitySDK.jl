
function exportSessionEvent(
    session::ExportSessionInput;
    options = nothing
  )
  #
  payload = Dict{String, Any}(
      "session" => session,
  )
  if (!isnothing(solveOptions))
      payload["options"] = options
  end
  response = navAbilityClient.mutate(MutationOptions(
      "solveSession",
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

exportSession( session::ExportSessionInput; options = nothing) = @async exportSessionEvent(session; options)
