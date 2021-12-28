struct QueryOptions

end

struct MutationOptions

end

struct NavAbilityClient
    query::Function
    mutate::Function
end

function NavAbilityWebsocketClient()::NavAbilityClient

end

function NavAbilityHttpsClient()::NavAbilityClient
    
end