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

"""
$(SIGNATURES)
Wait for the requests to complete, poll until done (new eventing version).

DevNotes:
- This version will in future replace the predecessor [`waitForCompletion`](@ref).
- Convert to JSON3.jl

Args:
    requestIds (List[str]): The request IDs that should be polled.
    maxSeconds (int, optional): Maximum wait time. Defaults to 60.
    expectedStatus (str, optional): Expected status message per request.
        Defaults to "Complete".
"""
function waitForCompletion2(client, eventId; maxSeconds=60, totalRequired=1, completeRequired=1)
    elapsedInSeconds = 0
    incrementInSeconds = 5
    while elapsedInSeconds < maxSeconds
        get_event_response = client.query(
            QueryOptions(
                "sdk_events_by_id",
                GQL_GET_EVENTS_BY_ID,
                Dict(
                    "eventId" => eventId
                )
            )
        ) |> fetch
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


"""
    $SIGNATURES
Natural less than for sorting, 

```julia
sort(["x10"; "x1", "x11"]; lt=NavAbilitySDK.natural_lt)
````

Notes
- duplicated from DFG, hence don't export
"""
function natural_lt(x::T, y::T) where T <: AbstractString
    # Adapted from https://rosettacode.org/wiki/Natural_sorting
    # split at digit to not digit change
    splitbynum(x::AbstractString) = split(x, r"(?<=\D)(?=\d)|(?<=\d)(?=\D)")
    #parse to Int
    numstringtonum(arr::Vector{<:AbstractString}) = [(n = tryparse(Int, e)) !== nothing ? n : e for e in arr]
    xarr = numstringtonum(splitbynum(x))
    yarr = numstringtonum(splitbynum(y))
    for i in 1:min(length(xarr), length(yarr))
        if typeof(xarr[i]) != typeof(yarr[i])
            return isa(xarr[i], Int)
        elseif xarr[i] == yarr[i]
            continue
        else
            return xarr[i] < yarr[i]
        end
    end
    return length(xarr) < length(yarr)
end
natural_lt(x::Symbol, y::Symbol) = natural_lt(string(x),string(y))
