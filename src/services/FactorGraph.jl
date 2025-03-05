function DFG.getGraph(client::NavAbilityClient, label::Symbol)
    fgId = getId(client.id, label)
    variables = Dict("fgId" => fgId)

    T = Vector{NvaNode{Factorgraph}}

    response = GQL.execute(
        client.client,
        QUERY_GET_GRAPH,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return handleQuery(response, "factorgraphs", label)
end

function addGraph!(client::NavAbilityClient, label::Symbol)
    @assert isValidLabel(label) "Factor graph label ($Label) is not a valid label"

    variables = Dict(
        "orgId" => client.id,
        "id" => getId(client.id, label),
        "label" => label,
        "_version" => DFG._getDFGVersion(),
    )

    # FactorGraphRemoteResponse
    T = @NamedTuple{factorgraphs::Vector{NvaNode{Factorgraph}}}

    response = GQL.execute(
        client.client,
        MUTATION_ADD_GRAPH,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return handleMutate(response, "addFactorgraphs", :factorgraphs)[1]
end

function deleteGraph!(fgclient::NavAbilityDFG)
    id = getId(fgclient.fg)

    nvars = length(listVariables(fgclient))
    nvars > 0 && error(
        "Only empty sessions can be deleted, $(getGraphLabel(fgclient)) still has $nvars variables.",
    )

    nfacts = length(listFactors(fgclient))
    nfacts > 0 && error(
        "Only empty sessions can be deleted, $(getGraphLabel(fgclient)) still has $nfacts factors.",
    )

    response = executeGql(fgclient, MUTATION_DELETE_GRAPH, (id = string(id),))

    return response.data
end

function listGraphs(client::NavAbilityClient)
    T = Vector{Dict{String, Vector{@NamedTuple{label::Symbol}}}}

    response = GQL.execute(
        client.client,
        QUERY_LIST_GRAPHS,
        T;
        variables = (id = client.id,),
        throw_on_execution_error = true,
    )

    return last.(handleQuery(response, "orgs", Symbol(client.id))["fgs"])
end

function DFG.listNeighbors(fgclient::NavAbilityDFG, label::Symbol)
    variables = (id = getId(fgclient.fg, label),)

    T = Vector{Dict{String, Vector{NamedTuple{(:label,), Tuple{Symbol}}}}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_LIST_NEIGHBORS,
        T;
        variables,
        throw_on_execution_error = true,
    )
    flbls =
        isempty(response.data["variables"]) ? Symbol[] :
        last.(response.data["variables"][1]["factors"])
    vlbls =
        isempty(response.data["factors"]) ? Symbol[] :
        last.(response.data["factors"][1]["variables"])

    return union(flbls, vlbls)
end

function DFG.exists(fgclient::NavAbilityDFG, label::Symbol)
    variables = (id = getId(fgclient.fg, label),)

    response = GQL.execute(
        fgclient.client.client,
        GQL_EXISTS_VARIABLE_FACTOR_LABEL;
        variables,
        throw_on_execution_error = true,
    )

    hasvar = !isempty(response.data["variables"])
    hasfac = !isempty(response.data["factors"])

    return hasvar || hasfac
end

#TODO update to standard pattern
function DFG.getGraphMetadata(dfg::NavAbilityDFG)
    
    response = executeGql(
        dfg,
        QUERY_GET_GRAPH_METADATA,
        (id = getId(dfg.fg),),
    )
    b64data = response.data["factorgraphs"][1]["metadata"]

    if isnothing(b64data) || b64data == ""
        return Dict{Symbol, DFG.SmallDataTypes}()
    else
        return JSON3.read(base64decode(b64data), Dict{Symbol, DFG.SmallDataTypes})
    end
end

function DFG.setGraphMetadata!(
    fgclient::NavAbilityDFG,
    smallData::Dict{Symbol, DFG.SmallDataTypes},
)
    meta = base64encode(JSON3.write(smallData))

    response = executeGql(
        fgclient,
        MUTATION_SET_GRAPH_METADATA,
        (id = getId(fgclient.fg), meta = meta),
    )

    return JSON3.read(
        base64decode(response.data["updateFactorgraphs"]["factorgraphs"][1]["metadata"]),
        Dict{Symbol, DFG.SmallDataTypes},
    )
end

## TAGS

function getGraphTags(cfg::NavAbilityDFG)

    response = executeGql(
        cfg,
        QUERY_GET_GRAPH_TAGS,
        (id = getId(cfg.fg),),
        #FIXME remove Union{Nothing...}
        # Vector{Dict{Symbol, Vector{Symbol}}},
        Vector{Dict{Symbol, Union{Nothing,Vector{Symbol}}}},
    )

    tls = handleQuery(response, "factorgraphs")[1][:tags]
    return isnothing(tls) ? Symbol[] : tls
end

function setGraphTags!(cfg::NavAbilityDFG, tags::Vector{Symbol})

    response = executeGql(
        cfg,
        MUTATION_SET_GRAPH_TAGS,
        (id = getId(cfg.fg), tags = tags),
        Dict{Symbol, Vector{Dict{Symbol, Vector{Symbol}}}},
    )

    return handleMutate(response, "updateFactorgraphs", :factorgraphs)[1][:tags]
end

function pushGraphTags!(cfg::NavAbilityDFG, tags::Vector{Symbol})

    response = executeGql(
        cfg,
        MUTATION_PUSH_GRAPH_TAGS,
        (id = getId(cfg.fg), tags_PUSH = tags),
        Dict{Symbol, Vector{Dict{Symbol, Vector{Symbol}}}},
    )

    return handleMutate(response, "updateFactorgraphs", :factorgraphs)[1][:tags]
end

## =======================================================================================
## Connect Factorgraph to other nodes
## =======================================================================================

function connect!(client, model::NvaNode{Model}, fg::NvaNode{Factorgraph})
    variables = Dict("modelId" => getId(model), "fgId" => getId(fg))

    response = executeGql(client, GQL_CONNECT_GRAPH_TO_MODEL, variables)

    return response.data["updateModels"]["info"]["relationshipsCreated"]
end

function connect!(client, agent::NvaNode{Agent}, fg::NvaNode{Factorgraph})
    variables = Dict("agentId" => getId(agent), "fgId" => getId(fg))

    response = executeGql(client, GQL_CONNECT_GRAPH_TO_AGENT, variables)

    return response.data["updateAgents"]["info"]["relationshipsCreated"]
end

function getAgents(client::NavAbilityClient, fg::NvaNode{Factorgraph})
    response = executeGql(
        client,
        QUERY_GET_GRAPHS_AGENTS,
        Dict("id" => getId(fg)),
        Vector{Dict{Symbol, Vector{NvaNode{Agent}}}},
    )
    return handleQuery(response, "factorgraphs")[1][:agents]
end
