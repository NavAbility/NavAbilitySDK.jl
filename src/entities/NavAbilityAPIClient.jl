# A transport-layer client
struct NavAbilityAPIClient
    host::String
    token::Union{Nothing, String}
    gqlClient::Diana.Client  
end
