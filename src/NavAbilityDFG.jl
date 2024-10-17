##
struct NavAbilityDFG{VT<:AbstractDFGVariable, FT<:AbstractDFGFactor} <: AbstractDFG{AbstractParams}
    client::NavAbilityClient
    fg::NvaNode{Factorgraph}
    agent::NvaNode{Agent}
    blobStores::Dict{Symbol, DFG.AbstractBlobStore}
end

DFG.getTypeDFGVariables(::NavAbilityDFG{T, <:AbstractDFGFactor}) where {T} = T
DFG.getTypeDFGFactors(::NavAbilityDFG{<:AbstractDFGVariable, T}) where {T} = T

function NavAbilityDFG(
    token::String,
    fgLabel::Symbol,
    agentLabel::Symbol;
    apiUrl::String = "https://api.navability.io",
    orgLabel::Union{Symbol, Nothing} = nothing,
    auth_token = nothing,
    authorize = nothing,
    storeLabel = :default,
    addAgentIfAbsent = false,
    addGraphIfAbsent = false,
    addRobotIfNotExists = nothing,
    addSessionIfNotExists = nothing,
    kwargs...
)
    if !isnothing(auth_token)
        @warn "kwarg auth_token is deprecated"
    end
    if !isnothing(authorize)
        @warn "kwarg authorize is deprecated"
    end
    return NavAbilityDFG(
        NavAbilityClient(token, apiUrl; orgLabel, kwargs...),
        fgLabel,
        agentLabel;
        storeLabel,
        addAgentIfAbsent,
        addGraphIfAbsent,
        addRobotIfNotExists,
        addSessionIfNotExists
    )
end

function NavAbilityDFG(
    client::NavAbilityClient,
    fgLabel::Symbol,
    agentLabel::Symbol;
    storeLabel = :default,
    addAgentIfAbsent = false,
    addGraphIfAbsent = false,
    addRobotIfNotExists = nothing,
    addSessionIfNotExists = nothing,
)
    @assert isValidLabel(fgLabel) "fgLabel: `$fgLabel` is not a valid label"
    @assert isValidLabel(agentLabel) "agentLabel: `$agentLabel` is not a valid label"
    @assert isValidLabel(storeLabel) "storeLabel: `$storeLabel` is not a valid label"
    
    #TODO remove Deprecated in v0.8
    if !isnothing(addRobotIfNotExists)
        @warn "addRobotIfNotExists is deprecated, use addAgentIfAbsent instead"
        addAgentIfAbsent = addRobotIfNotExists
    end
    if !isnothing(addSessionIfNotExists)
        @warn "addSessionIfNotExists is deprecated, use addGraphIfAbsent instead"
        addGraphIfAbsent = addSessionIfNotExists
    end

    if addAgentIfAbsent && !in(agentLabel, listAgents(client))
        agent = addAgent!(client, agentLabel)
    else
        agent = getAgent(client, agentLabel)
    end
    if addGraphIfAbsent && !in(fgLabel, listGraphs(client))
        fg = addGraph!(client, fgLabel)
    else
        fg = getGraph(client, fgLabel)
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