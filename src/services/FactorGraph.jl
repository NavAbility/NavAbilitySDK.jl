function DFG.getGraph(client::NavAbilityClient, label::Symbol)
    variables = (id = getId(client, label),)

    T = Vector{NvaNode{Graphroot}}

    response = executeGql(client, GQL_OPS[:getGraph], variables, T)

    return handleQuery(response, :graphs, label)
end

function addGraph!(client::NavAbilityClient, label::Symbol)
    @assert DFG.isValidLabel(label) "Factor graph label ($label) is not a valid label"
    
    # Create a minimal Graphroot with the label
    graph = DFG.Graphroot(; label)
    
    input = [
        GraphCreateInput(;
            id = getId(client, label),
            org = createConnect(client.id),
            getCommonProperties(GraphCreateInput, graph)...,
        ),
    ]

    variables = (input = input,)

    # GraphRemoteResponse
    T = @NamedTuple{graphs::Vector{NvaNode{Graphroot}}}

    response = executeGql(client, GQL_OPS[:addGraphs], variables, T)

    return handleMutate(response, :addGraphs, :graphs)[1]
end

function deleteGraph!(fgclient::NavAbilityDFG)
    id = getId(fgclient.fg)

    nvars = length(listVariables(fgclient))
    nvars > 0 && error(
        "Only empty sessions can be deleted, $(DFG.getGraphLabel(fgclient)) still has $nvars variables.",
    )

    nfacts = length(listFactors(fgclient))
    nfacts > 0 && error(
        "Only empty sessions can be deleted, $(DFG.getGraphLabel(fgclient)) still has $nfacts factors.",
    )

    response = executeGql(fgclient, GQL_OPS[:deleteGraph], (id = id,))

    return response[:deleteGraphs]["nodesDeleted"]
end

function listGraphs(client::NavAbilityClient)

    response = executeGql(
        client,
        GQL_OPS[:listGraphs],
        (id = client.id,),
        Vector{Dict{Symbol, Vector{@NamedTuple{label::Symbol}}}}
    )

    return last.(handleQuery(response, :orgs, Symbol(client.id))[:graphs])
end

#TODO continue from here after updating variables and factors
function DFG.listNeighbors(fgclient::NavAbilityDFG, label::Symbol)
    variables = (id = getId(fgclient.fg, label),)

    T = Vector{Dict{Symbol, Vector{NamedTuple{(:label,), Tuple{Symbol}}}}}

    response = executeGql(
        fgclient,
        GQL_OPS[:listNeighbors],
        variables,
        T
    )
    flbls =
        isempty(response[:variables]) ? Symbol[] :
        last.(response[:variables][1][:factors])
    vlbls =
        isempty(response[:factors]) ? Symbol[] :
        last.(response[:factors][1][:variables])

    return union(flbls, vlbls)
end

function DFG.hasVariable(fgclient::NavAbilityDFG, label::Symbol)
    response = executeGql(
        fgclient,
        GQL_OPS[:existsVariableFactorLabel],
        (id = getId(fgclient.fg, label),)
    )
    return !isempty(response[:variables])
end

function DFG.hasFactor(fgclient::NavAbilityDFG, label::Symbol)
    response = executeGql(
        fgclient,
        GQL_OPS[:existsVariableFactorLabel],
        (id = getId(fgclient.fg, label),)
    )
    return !isempty(response[:factors])
end

function DFG.exists(fgclient::NavAbilityDFG, label::Symbol)
    response = executeGql(
        fgclient,
        GQL_OPS[:existsVariableFactorLabel],
        (id = getId(fgclient.fg, label),)
    )
    hasvar = !isempty(response[:variables])
    hasfac = !isempty(response[:factors])
    return hasvar || hasfac
end

## TAGS
#TODO add to tests
function DFG.listGraphTags(cfg::NavAbilityDFG)

    response = executeGql(
        cfg,
        GQL_OPS[:listGraphTags],
        (id = getId(cfg.fg),),
        #FIXME remove Union{Nothing...}
        # Vector{Dict{Symbol, Vector{Symbol}}},
        Vector{Dict{Symbol, Vector{Symbol}}},
    )

    return handleQuery(response, :graphs)[1][:tags]
end

#TODO deprecate
function setGraphTags!(cfg::NavAbilityDFG, tags::Vector{Symbol})

    response = executeGql(
        cfg,
        GQL_OPS[:setGraphTags],
        (id = getId(cfg.fg), tags = tags),
        Dict{Symbol, Vector{Dict{Symbol, Vector{Symbol}}}},
    )

    return handleMutate(response, "updateGraphs", :factorgraphs)[1][:tags]
end

function pushGraphTags!(cfg::NavAbilityDFG, tags::Vector{Symbol})

    response = executeGql(
        cfg,
        GQL_OPS[:pushGraphTags],
        (id = getId(cfg.fg), tags_PUSH = tags),
        Dict{Symbol, Vector{Dict{Symbol, Vector{Symbol}}}},
    )

    return handleMutate(response, "updateGraphs", :factorgraphs)[1][:tags]
end

## =======================================================================================
## Connect Factorgraph to other nodes
## =======================================================================================

function connect!(client, model::NvaNode{Model}, fg::NvaNode{Graphroot})
    variables = Dict("modelId" => getId(model), "fgId" => getId(fg))

    response = executeGql(client, GQL_OPS[:connectGraphModel], variables)

    return response[:updateModels]["info"]["relationshipsCreated"]
end

function connect!(client, agent::NvaNode{Agent}, fg::NvaNode{Graphroot})
    variables = Dict("agentId" => getId(agent), "fgId" => getId(fg))

    response = executeGql(client, GQL_OPS[:connectGraphAgent], variables)

    return response[:updateAgents]["info"]["relationshipsCreated"]
end

function getAgents(client::NavAbilityClient, fg::NvaNode{Graphroot})
    response = executeGql(
        client,
        GQL_OPS[:getAgents_Graph],
        (id = getId(fg),),
        Vector{Dict{Symbol, Vector{NvaNode{Agent}}}},
    )
    return handleQuery(response, :graphs)[1][:agents]
end
