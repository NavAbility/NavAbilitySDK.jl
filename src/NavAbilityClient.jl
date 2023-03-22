struct DFGClient
    client::GQL.Client
    user::NamedTuple{(:id, :label), Tuple{UUID, String}}
    robot::NamedTuple{(:id, :label), Tuple{UUID, String}}
    session::NamedTuple{(:id, :label), Tuple{UUID, String}}
end

#TODO id OR label struct 
function DFGClient(client::GQL.Client, context::Context)
    return DFGClient(
        client,
        (id = context.user.id, label = context.user.label),
        (id = context.robot.id, label = context.robot.label),
        (id = context.session.id, label = context.session.label),
    )
end

function Base.show(io::IO, ::MIME"text/plain", c::DFGClient)
    summary(io, c)
    print(io, "\n  ")
    show(io, MIME("text/plain"), c.client)
    println(io)
    println(io, "  userLabel: ", c.user.label)
    println(io, "  robotLabel: ", c.robot.label)
    println(io, "  sessionLabel: ", c.session.label)
    return
end

function NavAbilityClient(
    apiUrl::String = "https://api.d1.navability.io";
    auth_token::String = "",
    authorize::Bool = 0 !== length(auth_token),
    kwargs...,
)
    headers =
        authorize ? Dict("Authorization" => "Bearer $auth_token") : Dict{String, String}()
    client = GQL.Client(apiUrl; headers, kwargs...)
    return client
end