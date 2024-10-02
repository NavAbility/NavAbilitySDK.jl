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
    println(io, "  id: ", string(s.id)[1:8])
    print(io, "  ")
    show(io, MIME("text/plain"), s.client)
end

function NavAbilityClient(
    orgId::UUID,
    apiUrl::String = "https://api.navability.io";
    auth_token::String = "",
    authorize::Bool = 0 !== length(auth_token),
    kwargs...,
)
    headers =
        authorize ? Dict("Authorization" => "Bearer $auth_token") : Dict{String, String}()
    client = GQL.Client(apiUrl; headers, kwargs...)
    return NavAbilityClient(orgId, client)  
end
