
"""
$(SIGNATURES)
Get all the statuses for a request.

Args:
    navAbilityClient (NavAbilityClient): The NavAbility client.
    id (String): The ID of the request that you want the statuses on.
"""
function getStatusMessages(navAbilityClient::NavAbilityClient, id::String)
    response = navAbilityClient.mutate(MutationOptions(
        "sdk_ls_statusmessages",
        GQL_GETSTATUSMESSAGES,
        Dict(
            "id" => id
        )
    ))
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(data["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    statusMessages = get(data,"statusMessages","Error")
    # TODO: What about marshalling?
    return statusMessages
end

"""
$(SIGNATURES)
Get the latest status message for a request.

Args:
    navAbilityClient (NavAbilityClient): The NavAbility client.
    id (String): The ID of the request that you want the latest status on.
"""
function getStatusLatest(navAbilityClient::NavAbilityClient, id::String)
    response = navAbilityClient.mutate(MutationOptions(
        "sdk_get_statuslatest",
        GQL_GETSTATUSLATEST,
        Dict(
            # "client" => client,
            "id" => id
        )
    ))
    rootData = JSON.parse(response.Data)
    if haskey(rootData, "errors")
        throw("Error: $(data["errors"])")
    end
    data = get(rootData,"data",nothing)
    if data === nothing return "Error" end
    statusMessage = get(data,"statusLatest","Error")
    # TODO: What about marshalling?
    return statusMessage
end

"""
$(SIGNATURES)
Helper function to get a dictionary of all latest statues for a list of results.

Args:
    navAbilityClient (NavAbilityClient): The NavAbility client.
    ids (Vector{String}): A list of the IDS that you want statuses on.
"""
function getStatusesLatest(navAbilityClient::NavAbilityClient, ids::Vector{String})
    return Dict(r=>getStatusLatest(navAbilityClient, r) for r in ids)
end