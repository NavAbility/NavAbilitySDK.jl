using Diana

struct QueryOptions
    name::String
    query::String
    variables::Dict{String,Any}
end

struct MutationOptions
    name::String
    mutation::String
    variables::Dict{String,Any}
end

struct NavAbilityClient
    query::Function
    mutate::Function
end

function NavAbilityWebsocketClient(apiUrl::String)::NavAbilityClient
    throw("Not implemented")
end

function NavAbilityHttpsClient(apiUrl::String="https://api.navability.io")::NavAbilityClient
    dianaClient = GraphQLClient(apiUrl)
    function query(options::QueryOptions)
        # NOTE, the query client library used is synchronous, locally converted to async for package consistency
        @async dianaClient.Query(options.query, operationName=options.name, vars=options.variables)
    end
    function mutate(options::MutationOptions)
        # NOTE, the query client library used is synchronous, locally converted to async for package consistency
        @async dianaClient.Query(options.mutation, operationName=options.name, vars=options.variables)
    end
    return NavAbilityClient(query, mutate)
end
