function getModel(client::NavAbilityClient, label::Symbol)
    response = executeGql(
        client,
        QUERY_GET_MODEL,
        (modelId = getId(client.id, label),),
        Vector{NvaNode{Model}}
    )
    return handleQuery(response, :models, label)
end

function getModels(client)
    response = executeGql(client, QUERY_GET_MODELS_ALL, Dict(), Vector{NvaNode{Model}})
    return handleQuery(response, :models)
end

function addModel!(client::NavAbilityClient, model::Model)
    @assert DFG.isValidLabel(getLabel(model)) "Model label ($(getLabel(model))) is not a valid label"

    input = [
        ModelCreateInput(;
            id = getId(client.id, getLabel(model)),
            org = createConnect(client.id),
            getCommonProperties(ModelCreateInput, model)...,
        ),
    ]
    response = executeGql(
        client,
        GQL_ADD_MODELS,
        (input = input,),
        @NamedTuple{models::Vector{NvaNode{Model}}}
    )

    return handleMutate(response, :addModels, :models)[1]
end

function getGraphs(client::NavAbilityClient, model::NvaNode{Model})
    response = executeGql(
        client,
        QUERY_GET_MODEL_GRAPHS,
        (id = getId(model),),
        Vector{Dict{Symbol, Vector{NvaNode{Graphroot}}}},
    )
    return handleQuery(response, :models)[1][:graphs]
end
