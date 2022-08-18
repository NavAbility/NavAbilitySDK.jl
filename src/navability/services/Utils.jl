"""
$(SIGNATURES)
Wait for the requests to complete, poll until done.

Args:
    requestIds (List[str]): The request IDs that should be polled.
    maxSeconds (int, optional): Maximum wait time. Defaults to 60.
    expectedStatus (str, optional): Expected status message per request.
        Defaults to "Complete".
"""
function waitForCompletion(
    navAbilityClient::NavAbilityClient,
    requestIds::AbstractVector{<:AbstractString};
    maxSeconds::Integer = 120,
    expectedStatuses::Union{Nothing,<:AbstractVector{<:AbstractString}} = nothing,
    exceptionMessage::AbstractString = "Requests did not complete in time")
#
    if expectedStatuses == Nothing
        expectedStatuses = ["Complete", "Failed"]
    end
    wait_time = maxSeconds
    tasksComplete = false
    while !tasksComplete
        statuses = values(fetch( getStatusesLatest(navAbilityClient, requestIds) ))
        tasksComplete = all(s["state"] in expectedStatuses for s in statuses)
        if tasksComplete
            return
        else
            sleep(2)
            wait_time -= 2
            wait_time <= 0 && throw(error(exceptionMessage))
        end
    end
end

# Dispatch for vector of Tasks
function waitForCompletion(
        navAbilityClient::NavAbilityClient,
        requestIds::AbstractVector{<:Task};
        kw...
    )
    #
    rids = String[]
    for reqId in requestIds
        push!(rids, fetch(reqId) |> string)
    end
    waitForCompletion(navAbilityClient, rids; kw...)
end

function waitForCompletion2(client, eventId; maxSeconds=60, totalRequired=1, completeRequired=1)
    elapsedInSeconds = 0
    incrementInSeconds = 5
    while elapsedInSeconds < maxSeconds
      get_event_response = client.query(QueryOptions(
        "sdk_events_by_id",
        GQL_GET_EVENTS_BY_ID,
        Dict(
          "eventId" => eventId
        )
        )) |> fetch
        payload = JSON.parse(get_event_response.Data)
        events = payload["data"]["test"]
        completeEvents = filter(event -> event["status"]["state"] == "Complete", events)
        if size(events)[1] >= totalRequired && size(completeEvents)[1] >= completeRequired
            return true
        end
        failedEvents = filter(event -> event["status"]["state"] == "Failed", payload["data"]["test"])
        if size(failedEvents)[1] > 0
            return false
        end
        elapsedInSeconds += incrementInSeconds
        sleep(incrementInSeconds)
    end
    return false
end

# Dispatch for vector of Tasks
function waitForCompletion2(
        navAbilityClient::NavAbilityClient,
        requestIds::AbstractVector{<:Task};
        kw...
    )
    #
    # rids = String[]
    for reqId in requestIds
        # push!(rids, fetch(reqId) |> string)
        waitForCompletion2(navAbilityClient, fetch(reqId) |> string; kw...)
    end
end

function waitForCompletionExportSession(client::NavAbilityClient, eventId::AbstractString)
    response = client.query(QueryOptions(
        GQL_GET_EXPORT_SESSION_COMPLETE_EVENT_BY_ID,
        Dict("eventId" => eventId)
    )) |> fetch
    payload = JSON.parse(response.Data)
    blobId = payload["data"]["test"][1]["data"]["blob"]["id"]
end

# helper functions to construct for most likely user object
function GraphVizApp(ct::Client; variableStartsWith=nothing)
    suffix = ""
    if !(variableStartsWith isa Nothing)
        suffix *= "&variableStartsWith"
        if 0<length(variableStartsWith)
            suffix *= "=$variableStartsWith"
        end
    end
    GraphVizApp("https://app.navability.io/cloud/graph/?userId=$(ct.userId)&robotStartsWith=$(ct.robotId)&sessionStartsWith=$(ct.sessionId)"*suffix)
end
function MapVizApp(ct::Client; variableStartsWith=nothing)
    suffix = ""
    if !(variableStartsWith isa Nothing)
        suffix *= "&variableStartsWith"
        if 0<length(variableStartsWith)
            suffix *= "=$variableStartsWith"
        end
    end
    MapVizApp("https://app.navability.io/cloud/map/?userId=$(ct.userId)&robotStartsWith=$(ct.robotId)&sessionStartsWith=$(ct.sessionId)"*suffix)
end

# overload show dispatch for convenient static and interactive links to NavAbility App visualizations
Base.show(io::IO, ::MIME"text/plain", gv::Union{GraphVizApp,MapVizApp}) = println(gv.url)
Base.show(io::IO, ::MIME"text/markdown", gv::GraphVizApp) = display("text/markdown", "[![Navigate to Factor Graph]($assetGraphVizImg)]($(gv.url))")
Base.show(io::IO, ::MIME"text/markdown", gv::MapVizApp) = display("text/markdown", "[![Navigate to Factor Graph]($assetGeomVizImg)]($(gv.url))")
