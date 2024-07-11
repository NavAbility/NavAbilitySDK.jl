struct DFGClient{VT<:AbstractDFGVariable, FT<:AbstractDFGFactor} <: AbstractDFG{AbstractParams}
    client::GQL.Client
    user::NamedTuple{(:id, :label), Tuple{UUID, String}}
    robot::NamedTuple{(:id, :label), Tuple{UUID, String}}
    session::NamedTuple{(:id, :label), Tuple{UUID, String}}
    blobStores::Dict{Symbol, DFG.AbstractBlobStore}
end

DFG.getTypeDFGVariables(::DFGClient{T, <:AbstractDFGFactor}) where {T} = T
DFG.getTypeDFGFactors(::DFGClient{<:AbstractDFGVariable, T}) where {T} = T

function DFGClient(client::GQL.Client, context::Context)
    return DFGClient{DFG.Variable, DFG.PackedFactor}(
        client,
        (id = context.user.id, label = context.user.label),
        (id = context.robot.id, label = context.robot.label),
        (id = context.session.id, label = context.session.label),
        Dict{Symbol, DFG.AbstractBlobStore}(
            :NAVABILITY => NavAbilityBlobStore(client, context.user.label),
        ),
    )
end

function DFGClient(
    userLabel::String,
    robotLabel::String,
    sessionLabel::String;
    apiUrl::String = "https://api.navability.io",
    auth_token::String = "",
    authorize::Bool = 0 !== length(auth_token),
    addRobotIfNotExists = false,
    addSessionIfNotExists = false,
)
    return DFGClient(
        NavAbilityClient(apiUrl; auth_token, authorize),
        userLabel,
        robotLabel,
        sessionLabel;
        addRobotIfNotExists,
        addSessionIfNotExists,
    )
end

function DFGClient(
    client::GQL.Client,
    userLabel::String,
    robotLabel::String,
    sessionLabel::String;
    addRobotIfNotExists = false,
    addSessionIfNotExists = false,
)
    context = Context(
        client,
        userLabel,
        robotLabel,
        sessionLabel;
        addRobotIfNotExists,
        addSessionIfNotExists,
    )

    return DFGClient{DFG.Variable, DFG.PackedFactor}(
        client,
        (id = context.user.id, label = context.user.label),
        (id = context.robot.id, label = context.robot.label),
        (id = context.session.id, label = context.session.label),
        Dict{Symbol, DFG.AbstractBlobStore}(
            :NAVABILITY => NavAbilityBlobStore(client, context.user.label),
        ),
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

Base.show(io::IO, c::DFGClient) = show(io, MIME"text/plain"(), c)

function NavAbilityClient(
    apiUrl::String = "https://api.navability.io";
    auth_token::String = "",
    authorize::Bool = 0 !== length(auth_token),
    kwargs...,
)
    headers =
        authorize ? Dict("Authorization" => "Bearer $auth_token") : Dict{String, String}()
    client = GQL.Client(apiUrl; headers, kwargs...)
    return client
end