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

function NavAbilityWebsocketClient( apiUrl::String="wss://api.navability.io/graphql")::NavAbilityClient
    throw("Not implemented")
end

function NavAbilityHttpsClient(
        apiUrl::String="https://api.navability.io";
        authorize::Bool=false 
    )::NavAbilityClient
    #
    dianaClient = GraphQLClient(apiUrl)

    # auth
    if authorize
        # FIXME, use Base.getpass instead of readline once VSCode supports getpass.
            # st = Base.getpass("Copy-paste auth token")
            # seekstart(st)
            # tok = read(st, String)
            # Base.shred!(st)
        println("  > VSCode ONLY WORKAROUND, input issue, see https://github.com/julia-vscode/julia-vscode/issues/785")
        println("  >  Workaround: first press 0 then enter, and then paste the token and hit enter a second time.")
        println("Copy-paste auth token: ")
        tok = readline(stdin)
        dianaClient.serverAuth("Bearer "*tok)
    end

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
