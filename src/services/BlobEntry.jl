# =========================================================================================
# Blobentry CRUD
# =========================================================================================
function createInput(fgclient, parent, entry::Blobentry)
    return NvaSDK.CreateInput(
        getId(fgclient, parent, entry.label),
        entry,
        Dict(:parent => NvaSDK.createConnect(fgclient, parent)),
    )
end

function DFG.getVariableBlobentry(fgclient::NavAbilityDFG, variableLabel::Symbol, label::Symbol)
    id = getId(fgclient.fg, variableLabel, label)

    T = Vector{DFG.Blobentry}

    response = executeGql(fgclient, GQL_OPS[:getBlobentry], (id = id,), T)

    return handleQuery(response, :blobentries, label)
end

function DFG.getVariableBlobentries(fgclient::NavAbilityDFG, variableLabel::Symbol)
    id = getId(fgclient.fg, variableLabel)
    T = Vector{@NamedTuple{blobentries::Vector{DFG.Blobentry}}}

    response = executeGql(fgclient, GQL_OPS[:getBlobentries], (id = id,), T)

    return handleQuery(response, :variables, :blobentries)[1]
end

function DFG.addVariableBlobentry!(
    fgclient::NavAbilityDFG,
    variableLabel::Symbol,
    entry::DFG.Blobentry,
)
    return addVariableBlobentries!(fgclient, variableLabel, [entry])[1]
end

function DFG.addVariableBlobentries!(
    fgclient::NavAbilityDFG,
    variableLabel::Symbol,
    entries::Vector{DFG.Blobentry},
)
    varId = getId(fgclient.fg, variableLabel)
    connect = createConnect(varId)
    # TODO we can probably standardise this
    input = map(entries) do entry
        NvaSDK.CreateInput(
            getId(fgclient.fg, variableLabel, entry.label),
            entry,
            Dict(:parent => (Variable = connect,)),
        )
    end

    T = @NamedTuple{blobentries::Vector{Blobentry}}

    response = executeGql(
        fgclient,
        GQL_OPS[:addBlobentries],
        (blobentries = input,),
        T; #FIXME BlobentryResponse
    )
    return handleMutate(response, :addBlobentries, :blobentries)
end

function DFG.listVariableBlobentries(fgclient::NavAbilityDFG, variableLabel::Symbol)
    T = Vector{Dict{Symbol, Vector{@NamedTuple{label::Symbol}}}}

    response = executeGql(
        fgclient,
        GQL_OPS[:listBlobentries],
        (id = getId(fgclient.fg, variableLabel),),
        T;
    )

    return last.(handleQuery(response, :variables, variableLabel)[:blobentries])
end

#TODO update

function DFG.deleteVariableBlobentry!(fgclient::NavAbilityDFG, varLabel::Symbol, entryLabel::Symbol)
    response = executeGql(
        fgclient,
        GQL_OPS[:deleteBlobentry],
        (id = getId(fgclient.fg, varLabel, entryLabel),),
    )
    return response[:deleteBlobentries][:nodesDeleted]
end

function DFG.deleteAgentBlobentry!(fgclient::NavAbilityDFG, label::Symbol)
    response = executeGql(
        fgclient,
        GQL_OPS[:deleteBlobentry],
        (id = getId(fgclient.agent, label),),
    )
    return response[:deleteBlobentries][:nodesDeleted]
end

function DFG.deleteGraphBlobentry!(fgclient::NavAbilityDFG, label::Symbol)
    response = executeGql(
        fgclient,
        GQL_OPS[:deleteBlobentry],
        (id = getId(fgclient.fg, label),),
    )
    return response[:deleteBlobentries][:nodesDeleted]
end

#TODO Factor Blobentry
# function DFG.deleteFactorBlobentry!(fgclient::NavAbilityDFG, factorLabel::Symbol, entryLabel::Symbol)
#     response = executeGql(
#         fgclient,
#         GQL_OPS[:deleteBlobentry],
#         (id = getId(fgclient.fg, factorLabel, entryLabel),),
#     )
#     return response[:deleteBlobentries][:nodesDeleted]
# end

function DFG.deleteModelBlobentry!(client::NavAbilityClient, model::NvaNode{Model}, label::Symbol)
    response = executeGql(
        client,
        GQL_OPS[:deleteBlobentry],
        (id = getId(model, label),),
    )
    return response[:deleteBlobentries][:nodesDeleted]
end
# =========================================================================================
# Blobentry CRUD on other nodes
# =========================================================================================

function DFG.getGraphBlobentry(fgclient::NavAbilityDFG, label::Symbol)

    response = executeGql(
        fgclient,
        GQL_OPS[:getBlobentry],
        (id =  getId(fgclient.fg, label),),
        Vector{DFG.Blobentry}
    )

    return handleQuery(response, :blobentries, label)
end

function DFG.getGraphBlobentries(
    fgclient::NavAbilityDFG;
    labelFilter::Union{Nothing, Base.Fix2} = nothing,
)
    id = getId(fgclient.fg)

    if isnothing(labelFilter)
        variables = (id = id,)
    else
        variables = (id = id, entrywhere = (label = whereFilter(labelFilter),))
    end

    response = executeGql(
        fgclient,
        GQL_OPS[:getGraphBlobentries],
        variables,
        Vector{@NamedTuple{blobentries::Vector{DFG.Blobentry}}}
    )

    return handleQuery(response, :graphs, DFG.getGraphLabel(fgclient))[1]
end

function DFG.getAgentBlobentry(client::NavAbilityClient, agentLabel::Symbol, label::Symbol)

    response = executeGql(
        client,
        GQL_OPS[:getBlobentry],
        (id = getId(client, agentLabel, label),),
        Vector{DFG.Blobentry}
    )

    return handleQuery(response, :blobentries, label)
end

function DFG.getAgentBlobentry(fg::NavAbilityDFG, label::Symbol)
    getAgentBlobentry(fg.client, DFG.getAgentLabel(fg), label)
end

function DFG.getAgentBlobentries(
    client::NavAbilityClient,
    agent::NvaNode{Agent};
    labelFilter::Union{Nothing, Base.Fix2} = nothing,
)

    id = getId(agent)

    if isnothing(labelFilter)
        variables = (id = id,)
    else
        variables = (id = id, entrywhere = whereFilterStr(:label, labelFilter))
    end

    T = Vector{@NamedTuple{blobentries::Vector{DFG.Blobentry}}}

    response = executeGql(
        client,
        GQL_OPS[:getAgentBlobentries],
        variables,
        T
    )

    return handleQuery(response, :agents, :blobentries)[1]
end

function DFG.getAgentBlobentries(client::NavAbilityClient, label::Symbol; kwargs...)
    return getAgentBlobentries(client, getAgent(client, label); kwargs...)
end
function DFG.getAgentBlobentries(fgclient::NavAbilityDFG; kwargs...)
    getAgentBlobentries(fgclient.client, fgclient.agent; kwargs...)
end

function DFG.getModelBlobentry(client::NavAbilityClient, modelLabel::Symbol, label::Symbol)
    id = getId(client, modelLabel, label)

    T = Vector{DFG.Blobentry}

    response = executeGql(client, GQL_OPS[:getBlobentry], (id = id,), T)

    return handleQuery(response, :blobentries, label)
end

function DFG.getModelBlobentries(
    client::NavAbilityClient,
    model::NvaNode{Model};
    labelFilter::Union{Nothing, Base.Fix2} = nothing,
)

    id = getId(model)

    if isnothing(labelFilter)
        variables = (id = id,)
    else
        variables = (id = id, entrywhere = whereFilterStr(:label, labelFilter))
    end

    T = Vector{@NamedTuple{blobentries::Vector{DFG.Blobentry}}}

    response = executeGql(
        client,
        GQL_OPS[:getModelBlobentries],
        variables,
        T
    )

    return handleQuery(response, :models, :blobentries)[1]
end

function addBlobentries!(
    fgclient::Union{NavAbilityDFG, NavAbilityClient},
    parent::Union{NvaNode, DFG.AbstractGraphVariable, DFG.AbstractGraphFactor},
    entries::Vector{DFG.Blobentry},
)

    input = map(entries) do entry
        createInput(fgclient, parent, entry)
    end

    T = @NamedTuple{blobentries::Vector{Blobentry}}

    response = executeGql(fgclient, GQL_OPS[:addBlobentries], (blobentries = input,), T)

    return handleMutate(response, :addBlobentries, :blobentries)
end

function DFG.addGraphBlobentries!(fgclient::NavAbilityDFG, entries::Vector{DFG.Blobentry})
    return addBlobentries!(fgclient, fgclient.fg, entries)
end

function DFG.addGraphBlobentry!(fgclient::NavAbilityDFG, entry::DFG.Blobentry)
    return addBlobentries!(fgclient, fgclient.fg, [entry])[1]
end

function DFG.addAgentBlobentries!(fgclient::NavAbilityDFG, entries::Vector{DFG.Blobentry})
    return addBlobentries!(fgclient, fgclient.agent, entries)
end

function DFG.addAgentBlobentry!(fgclient::NavAbilityDFG, entry::DFG.Blobentry)
    return addBlobentries!(fgclient, fgclient.agent, [entry])[1]
end

function DFG.addModelBlobentries!(nva::NavAbilityModel, entries::Vector{DFG.Blobentry})
    return addBlobentries!(nva.client, nva.model, entries)
end
function DFG.addModelBlobentries!(client::NavAbilityClient, model::NvaNode{Model}, entries::Vector{DFG.Blobentry})
    return addBlobentries!(client, model, entries)
end
function DFG.addModelBlobentry!(client::NavAbilityClient, model::NvaNode{Model}, entry::DFG.Blobentry)
    return addBlobentries!(client, model, [entry])[1]
end

function DFG.listGraphBlobentries(fgclient::NavAbilityDFG)
    variables = (id = getId(fgclient.fg),)

    T = Vector{Dict{Symbol, Vector{@NamedTuple{label::Symbol}}}}

    response = executeGql(fgclient, GQL_OPS[:listGraphBlobentries], variables, T)

    return last.(handleQuery(response, :graphs, fgclient.fg.label)[:blobentries])
end

function DFG.listAgentBlobentries(fgclient::NavAbilityDFG)
    listAgentBlobentries(fgclient.client, fgclient.agent)
end

function DFG.listAgentBlobentries(client::NavAbilityClient, agent::NvaNode{Agent})
    variables = (id = getId(agent),)

    T = Vector{Dict{Symbol, Vector{@NamedTuple{label::Symbol}}}}

    response = executeGql(client, GQL_OPS[:listAgentBlobentries], variables, T)

    return last.(handleQuery(response, :agents, agent.label)[:blobentries])
end

function DFG.listModelBlobentries(client::NavAbilityClient, label::Symbol)
    variables = (id = getId(client, label),)

    T = Vector{Dict{Symbol, Vector{@NamedTuple{label::Symbol}}}}

    response = executeGql(client, GQL_OPS[:listModelBlobentries], variables, T)

    return last.(handleQuery(response, :models, label)[:blobentries])
end

#TODO
# addFactorBlobentries!
