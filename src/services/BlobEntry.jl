# =========================================================================================
# BlobEntry CRUD
# =========================================================================================

function DFG.getBlobEntry(fgclient::NavAbilityDFG, variableLabel::Symbol, label::Symbol)

    id = getId(fgclient.fg, variableLabel, label)

    T = Vector{DFG.BlobEntry}

    response = executeGql(fgclient, GQL_GET_BLOBENTRY, (id=id,), T)

    return handleQuery(response, "blobEntries", label)
end

function DFG.getBlobEntries(fgclient::NavAbilityDFG, variableLabel::Symbol)

    id = getId(fgclient.fg, variableLabel)
    T = Vector{@NamedTuple{blobEntries::Vector{DFG.BlobEntry}}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_GET_BLOBENTRIES,
        T;
        variables = (id=id,),
        throw_on_execution_error = true,
    )

    return handleQuery(response, "variables", :blobEntries)[1]

end

function DFG.addBlobEntry!(fgclient::NavAbilityDFG, variableLabel::Symbol, entry::DFG.BlobEntry)
    return addBlobEntries!(fgclient, variableLabel, [entry])[1]
end

function DFG.addBlobEntries!(
    fgclient::NavAbilityDFG,
    variableLabel::Symbol,
    entries::Vector{DFG.BlobEntry},
)
    varId = getId(fgclient.fg, variableLabel)
    connect = createConnect(varId)

    # TODO we can probably standardise this
    input = map(entries) do entry
        return BlobEntryCreateInput(;
            getCommonProperties(BlobEntryCreateInput, entry)...,
            id = getId(fgclient.fg, variableLabel, entry.label),
            parent = (Variable=connect,),
        )
    end

    T = @NamedTuple{blobEntries::Vector{BlobEntry}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_ADD_BLOBENTRIES,
        T; #FIXME BlobEntryResponse
        # BlobEntryResponse;
        variables = (blobEntries=input,),
        throw_on_execution_error = true,
    )
    return handleMutate(response, "addBlobEntries", :blobEntries)
end

# another way would be like this:
# GQL.mutate(client, "addBlobEntries", Dict("input"=>input), NVA.BlobEntryResponse; output_fields=#TODO, verbose=2)

function DFG.listBlobEntries(fgclient::NavAbilityDFG, variableLabel::Symbol)

    id = getId(fgclient.fg, variableLabel)
    variables = (id=id,)

    # T = (NamedTuple{(:solveKey,), Tuple{Symbol}})
    T = Vector{Dict{String, Vector{@NamedTuple{label::Symbol}}}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_LIST_BLOBENTRIES,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return last.(handleQuery(response, "variables", variableLabel)["blobEntries"])
end

#TODO delete and update

function DFG.deleteBlobEntry!(fgclient::NavAbilityDFG, varLabel::Symbol, entry::BlobEntry)

    id = getId(fgclient.fg, varLabel, entry.label)
    variables = (id=id,)

    response = GQL.execute(
        fgclient.client.client,
        GQL_DELETE_BLOBENTRY,;
        variables,
        throw_on_execution_error = true,
    )
    #TOOD check response.data["deleteBlobEntry"]["nodesDeleted"]
    return entry
end

function DFG.deleteBlobEntry!(fgclient::NavAbilityDFG, varLabel::Symbol, label::Symbol)
    entry = getBlobEntry(fgclient, varLabel, label)
    return deleteBlobEntry!(fgclient, varLabel, entry)
end

# =========================================================================================
# BlobEntry CRUD on other nodes
# =========================================================================================

function DFG.getGraphBlobEntry(fgclient::NavAbilityDFG, label::Symbol)
    id = getId(fgclient.fg, label)

    T = Vector{DFG.BlobEntry}

    response = GQL.execute(
        fgclient.client.client,
        GQL_GET_BLOBENTRY,
        T;
        variables=(id=id,),
        throw_on_execution_error = true,
    )

    return handleQuery(response, "blobEntries", label)
end

function DFG.getGraphBlobEntries(fgclient::NavAbilityDFG)

    id = getId(fgclient.fg)
    T = Vector{@NamedTuple{blobEntries::Vector{DFG.BlobEntry}}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_GET_FG_BLOBENTRIES,
        T;
        variables = (id=id,),
        throw_on_execution_error = true,
    )

    return handleQuery(response, "factorgraphs", :blobEntries)[1]
end


function DFG.getAgentBlobEntry(fgclient::NavAbilityDFG, label::Symbol)
    id = getId(fgclient.agent, label)

    T = Vector{DFG.BlobEntry}

    response = GQL.execute(
        fgclient.client.client,
        GQL_GET_BLOBENTRY,
        T;
        variables=(id=id,),
        throw_on_execution_error = true,
    )

    return handleQuery(response, "blobEntries", label)
end

function DFG.getAgentBlobEntries(client::NavAbilityClient, agent::NvaNode{Agent})
    id = getId(agent)

    T = Vector{@NamedTuple{blobEntries::Vector{DFG.BlobEntry}}}

    response = GQL.execute(
        client.client,
        GQL_GET_AGENT_BLOBENTRIES,
        T;
        variables = (id=id,),
        throw_on_execution_error = true,
    )

    return handleQuery(response, "agents", :blobEntries)[1]
end

function DFG.getAgentBlobEntries(client::NavAbilityClient, label::Symbol)
    return getAgentBlobEntries(client, getAgent(client, label))
end

function DFG.addBlobEntries!(
    fgclient,
    parent::Union{NvaNode, DFG.AbstractDFGVariable, DFG.AbstractDFGFactor},
    entries::Vector{DFG.BlobEntry}
)  
    input = map(entries) do entry
        return BlobEntryCreateInput(;
            getCommonProperties(BlobEntryCreateInput, entry)...,
            id = getId(fgclient, parent, entry.label),
            parent = createConnect(fgclient, parent),
            size = isnothing(entry.size) ? "" : entry.size, #FIXME remove once size is "required"
        )
    end

    T = @NamedTuple{blobEntries::Vector{BlobEntry}}

    response = executeGql(fgclient, GQL_ADD_BLOBENTRIES, (blobEntries=input,), T)

    return handleMutate(response, "addBlobEntries", :blobEntries)

end

function DFG.addGraphBlobEntries!(fgclient::NavAbilityDFG, entries::Vector{DFG.BlobEntry})
    return addBlobEntries!(fgclient, fgclient.fg, entries)
end
function DFG.addAgentBlobEntries!(fgclient::NavAbilityDFG, entries::Vector{DFG.BlobEntry})
    return addBlobEntries!(fgclient, fgclient.agent, entries)
end
function DFG.addModelBlobEntries!(nva::NavAbilityModel, entries::Vector{DFG.BlobEntry})
    return addBlobEntries!(nva.client, nva.model, entries)
end

function DFG.listGraphBlobEntries(fgclient::NavAbilityDFG)

    variables = (id=getId(fgclient.fg),)

    T = Vector{Dict{String, Vector{@NamedTuple{label::Symbol}}}}

    response = executeGql(fgclient, GQL_LIST_FACTORGRAPH_BLOBENTRIES, variables, T)

    return last.(handleQuery(response, "factorgraphs", fgclient.fg.label)["blobEntries"])

end

function DFG.listAgentBlobEntries(fgclient::NavAbilityDFG)
    getAgentBlobEntries(fgclient.client, fgclient.agent)
end

function DFG.listAgentBlobEntries(client::NavAbilityClient, agent::NvaNode{Agent})

    variables = (id=getId(agent),)

    T = Vector{Dict{String, Vector{@NamedTuple{label::Symbol}}}}

    response = executeGql(client, GQL_LIST_AGENT_BLOBENTRIES, variables, T)

    return last.(handleQuery(response, "agents", agent.label)["blobEntries"])

end

#TODO
# addFactorBlobEntries!