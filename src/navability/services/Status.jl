
"""
$(SIGNATURES)
Get all the statuses for a request.

Args:
    navAbilityClient (NavAbilityClient): The NavAbility client.
    id (String): The ID of the request that you want the statuses on.
"""
function getStatusMessagesEvent(navAbilityClient::NavAbilityClient, id::String)
    response = navAbilityClient.mutate(MutationOptions(
        "sdk_ls_statusmessages",
        GQL_GETSTATUSMESSAGES,
        Dict(
            "id" => id
        )
    )) |> fetch
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(rootData["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    statusMessages = get(data,"statusMessages","Error")
    # TODO: What about marshalling?
    return statusMessages
end

getStatusMessages(navAbilityClient::NavAbilityClient, id::String) = @async getStatusMessagesEvent(navAbilityClient, id)

"""
$(SIGNATURES)
Get the latest status message for a request.

Args:
    navAbilityClient (NavAbilityClient): The NavAbility client.
    id (String): The ID of the request that you want the latest status on.
"""
function getStatusLatestEvent(navAbilityClient::NavAbilityClient, id::String)
    response = navAbilityClient.mutate(MutationOptions(
        "sdk_get_statuslatest",
        GQL_GETSTATUSLATEST,
        Dict(
            # "client" => client,
            "id" => id
        )
    )) |> fetch
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(rootData["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    statusMessage = get(data,"statusLatest","Error")
    # TODO: What about marshalling?
    return statusMessage
end

getStatusLatest(navAbilityClient::NavAbilityClient, id::String) = @async getStatusLatestEvent(navAbilityClient, id)

"""
$(SIGNATURES)
Helper function to get a dictionary of all latest statues for a list of results.

Args:
    navAbilityClient (NavAbilityClient): The NavAbility client.
    ids (Vector{String}): A list of the IDS that you want statuses on.
"""
function getStatusesLatest(navAbilityClient::NavAbilityClient, ids::Vector{String})
    @async begin
        return Dict(r=>fetch(getStatusLatest(navAbilityClient, r)) for r in ids)
    end
end