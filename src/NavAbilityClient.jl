#TODO use id or label for org?
# constructor can get the Org from the chosen api using the label, label should then be unique
# maybe org should get a client number to use that is unique
struct NavAbilityClient
    id::UUID
    client::GQL.Client
    # org::Org
end

#TODO DEPRECATE add orgId
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


struct DFGClient{VT<:AbstractDFGVariable, FT<:AbstractDFGFactor} <: AbstractDFG{AbstractParams}
    client::NavAbilityClient
    fg::FactorGraphRemote
    agent::AgentRemote
    blobStores::Dict{Symbol, DFG.AbstractBlobStore}
end

DFG.getTypeDFGVariables(::DFGClient{T, <:AbstractDFGFactor}) where {T} = T
DFG.getTypeDFGFactors(::DFGClient{<:AbstractDFGVariable, T}) where {T} = T

# #FIXME DEPRECATE DFGClient(client::GQL.Client, context::Context, storeLabel=:NAVABILITY)
# function DFGClient(client::GQL.Client, context::Context, storeLabel=:NAVABILITY)
#     return DFGClient{DFG.Variable, DFG.PackedFactor}(
#         client,
#         (id = context.user.id, label = context.user.label),
#         (id = context.robot.id, label = context.robot.label),
#         (id = context.session.id, label = context.session.label),
#         Dict{Symbol, DFG.AbstractBlobStore}(
#             storeLabel => NavAbilityBlobStore(client, context.user.label),
#         ),
#     )
# end

# FIXME DEPRECATE
# function DFGClient(
#     userLabel::String,
#     robotLabel::String,
#     sessionLabel::String;
#     apiUrl::String = "https://api.navability.io",
#     auth_token::String = "",
#     authorize::Bool = 0 !== length(auth_token),
#     addRobotIfNotExists = false,
#     addSessionIfNotExists = false,
# )

function DFGClient(
    orgId::UUID,
    agentLabel::Symbol,
    fgLabel::Symbol;
    apiUrl::String = "https://api.navability.io",
    auth_token::String = "",
    authorize::Bool = 0 !== length(auth_token),
    addRobotIfNotExists = false,
    addSessionIfNotExists = false,
)
    return DFGClient(
        NavAbilityClient(orgId, apiUrl; auth_token, authorize),
        fgLabel,
        agentLabel;
        addRobotIfNotExists,
        addSessionIfNotExists,
    )
end

function DFGClient(
    client::NavAbilityClient,
    fgLabel::Symbol,
    agentLabel::Symbol;
    storeLabel = :NAVABILITY,
    addRobotIfNotExists = false,
    addSessionIfNotExists = false,
)
    # context = Context(
    #     client,
    #     userLabel,
    #     robotLabel,
    #     sessionLabel;
    #     addRobotIfNotExists,
    #     addSessionIfNotExists,
    # )
    fg = getFg(client, fgLabel)
    agent = getAgent(client, agentLabel)

    return DFGClient{DFG.Variable, DFG.PackedFactor}(
        client,
        fg,
        agent,
        Dict{Symbol, DFG.AbstractBlobStore}(
            storeLabel => NavAbilityBlobStore(storeLabel, client)
        ),
    )
end

function Base.show(io::IO, ::MIME"text/plain", c::DFGClient)
    summary(io, c)
    # print(io, "\n  ")
    # show(io, MIME("text/plain"), c.client)
    println(io)
    println(io, "  Agent: ", c.agent.label)
    println(io, "  FactorGraph: ", c.fg.label)
    println(io, "  BlobStores: ", keys(c.blobStores))
    return
end

# Base.show(io::IO, c::DFGClient) = show(io, MIME"text/plain"(), c)

DFG.getUserLabel(fg::DFGClient) = "user label deprecated"
DFG.getRobotLabel(fg::DFGClient) = "robot deprecated"
DFG.getSessionLabel(fg::DFGClient) = "session deprecated"