#TODO use id or label for org?
# constructor can get the Org from the chosen api using the label, label should then be unique
# maybe org should get a client number to use that is unique
struct NavAbilityClient
    id::UUID
    client::GQL.Client
    # org::Org
end

function Base.show(io::IO, ::MIME"text/plain", s::NavAbilityClient)
    summary(io, s)
    println(io)
    println(io, "  id: ", s.id)
    print(io, "  ")
    show(io, MIME("text/plain"), s.client)
end

function NavAbilityClient(
    auth_token::String,
    apiUrl::String = "https://api.navability.io";
    orgLabel::Union{Symbol, Nothing} = nothing,
    kwargs...,
)
    headers = Dict("Authorization" => "Bearer $auth_token")
    client = GQL.Client(apiUrl; headers, kwargs...)
    if isnothing(orgLabel)
        id = getOrgs(client)[1].id
    else
        id = getOrg(client, orgLabel).id
    end
    return NavAbilityClient(id, client)
end

function NavAbilityClient(;
    auth_token::String = "",
    authorize::Bool = 0 !== length(auth_token),
    kwargs...,
) 
    apiUrl = "https://api.navability.io"
    @warn "Deprecated: NavAbilityClient kwarg `auth_token` is now a required parameter"
    return NavAbilityClient(auth_token, apiUrl; kwargs...)  
end
