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
    maxSeconds::Integer = 60,
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
    kw...)
    #
    rids = fetch.(requestIds) .|> string
    waitForCompletion(navAbilityClient, rids; kw...)
end
