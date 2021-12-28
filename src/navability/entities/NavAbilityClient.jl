using Diana

struct QueryOptions

end

struct MutationOptions

end

struct NavAbilityClient
    query::Function
    mutate::Function
end

function NavAbilityHttpsClient(apiUrl::String)::NavAbilityClient
    dianaClient = GraphQLClient(apiUrl)
    return NavAbilityClient(dianaClient.Query,dianaClient.Query)
end