##
struct NavAbilityDFG{VT <: AbstractGraphVariable, FT <: AbstractGraphFactor} <:
       AbstractDFG{VT, FT}
    client::NavAbilityClient
    fg::NvaNode{Graphroot}
    agent::NvaNode{Agent}
    blobStores::Dict{Symbol, DFG.AbstractBlobstore}
end

DFG.getAgent(dfg::NavAbilityDFG) = dfg.agent
DFG.getGraph(dfg::NavAbilityDFG) = dfg.fg

function NavAbilityDFG(
    token::String,
    fgLabel::Symbol,
    agentLabel::Union{Nothing, Symbol} = nothing;
    apiUrl::String = "https://api.navability.io",
    orgLabel::Union{Symbol, Nothing} = nothing,
    storeLabel = :default,
    addAgentIfAbsent = false,
    addGraphIfAbsent = false,
    kwargs...,
)
    return NavAbilityDFG(
        NavAbilityClient(token, apiUrl; orgLabel, kwargs...),
        fgLabel,
        agentLabel;
        storeLabel,
        addAgentIfAbsent,
        addGraphIfAbsent,
    )
end

function NavAbilityDFG(
    client::NavAbilityClient,
    fgLabel::Symbol,
    agentLabel::Union{Nothing, Symbol} = nothing;
    storeLabel = :default,
    addAgentIfAbsent = false,
    addGraphIfAbsent = false,
)
    @assert DFG.isValidLabel(fgLabel) "fgLabel: `$fgLabel` is not a valid label"
    @assert isnothing(agentLabel) || DFG.isValidLabel(agentLabel) "agentLabel: `$agentLabel` is not a valid label"
    @assert DFG.isValidLabel(storeLabel) "storeLabel: `$storeLabel` is not a valid label"

    fg_tsk = @async begin
        if addGraphIfAbsent && !in(fgLabel, listGraphs(client))
            addGraph!(client, fgLabel)
        else
            #TODO maybe rather check if graph exist.
            # getGraph(client, fgLabel)
            NvaNode{Graphroot}(client.id, fgLabel)
        end
    end

    agent_tsk = @async begin
        if isnothing(agentLabel)
            fg = fetch(fg_tsk)
            agents = getAgents(client, fg)
            isempty(agents) && error(
                "No agents linked to graph $fgLabel, please provide an agentLabel",
            )
            length(agents) > 1 && error(
                "Multiple agents linked to graph $fgLabel, please provide an agentLabel",
            )
            (link = false, agent = agents[1])
        elseif addAgentIfAbsent && !in(agentLabel, listAgents(client))
            (link = true, agent = addAgent!(client, Agent(; label = agentLabel)))
        else
            # getAgent(client, agentLabel)
            #FIXME we don't know if we should link here so we don't
            (link = false, agent = NvaNode{Agent}(client.id, agentLabel))
        end
    end

    (;link, agent) = fetch(agent_tsk)
    fg = fetch(fg_tsk)
    link && @async connect!(client, agent, fg)

    return NavAbilityDFG{DFG.VariableDFG, DFG.FactorDFG}(
        client,
        fg,
        agent,
        Dict{Symbol, DFG.AbstractBlobstore}(
            storeLabel => NavAbilityBlobStore(client, storeLabel),
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
