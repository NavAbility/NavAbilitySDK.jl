##
struct NavAbilityDFG{VT<:AbstractDFGVariable, FT<:AbstractDFGFactor} <: AbstractDFG{AbstractParams}
    client::NavAbilityClient
    fg::NvaFactorGraph
    agent::NvaAgent
    blobStores::Dict{Symbol, DFG.AbstractBlobStore}
end

DFG.getTypeDFGVariables(::NavAbilityDFG{T, <:AbstractDFGFactor}) where {T} = T
DFG.getTypeDFGFactors(::NavAbilityDFG{<:AbstractDFGVariable, T}) where {T} = T

function NavAbilityDFG(
    orgId::UUID,
    fgLabel::Symbol,
    agentLabel::Symbol;
    apiUrl::String = "https://api.navability.io",
    auth_token::String = "",
    authorize::Bool = 0 !== length(auth_token),
    kwargs...
)
    return NavAbilityDFG(
        NavAbilityClient(orgId, apiUrl; auth_token, authorize),
        fgLabel,
        agentLabel;
        kwargs...
    )
end

function NavAbilityDFG(
    client::NavAbilityClient,
    fgLabel::Symbol,
    agentLabel::Symbol;
    storeLabel = :default,
    addAgentIfAbsent = false,
    addFgIfAbsent = false,
    addRobotIfNotExists = nothing,
    addSessionIfNotExists = nothing,
)
    #TODO remove Deprecated in v0.8
    if !isnothing(addRobotIfNotExists)
        @warn "addRobotIfNotExists is deprecated, use addAgentIfAbsent instead"
        addAgentIfAbsent = addRobotIfNotExists
    end
    if !isnothing(addSessionIfNotExists)
        @warn "addSessionIfNotExists is deprecated, use addFgIfAbsent instead"
        addFgIfAbsent = addSessionIfNotExists
    end

    if addAgentIfAbsent && !in(agentLabel, listAgents(client))
        agent = addAgent!(client, agentLabel)
    else
        agent = getAgent(client, agentLabel)
    end
    if addFgIfAbsent && !in(fgLabel, listFgs(client))
        fg = addFg!(client, fgLabel)
    else
        fg = getFg(client, fgLabel)
    end

    return NavAbilityDFG{DFG.Variable, DFG.PackedFactor}(
        client,
        fg,
        agent,
        Dict{Symbol, DFG.AbstractBlobStore}(
            storeLabel => NavAbilityBlobStore(client, storeLabel)
        ),
    )
end

function Base.show(io::IO, ::MIME"text/plain", c::NavAbilityDFG)
    summary(io, c)
    # print(io, "\n  ")
    # show(io, MIME("text/plain"), c.client)
    println(io)
    println(io, "  FactorGraph: ", c.fg.label)
    println(io, "  Agent: ", c.agent.label)
    println(io, "  BlobStores: ", keys(c.blobStores))
    return
end
