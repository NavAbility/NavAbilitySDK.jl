function getModel(client::NavAbilityClient, label::Symbol)
    id = getId(client.id, label)
    variables = Dict("modelId" => id)

    T = Vector{NvaNode{Model}}

    response = executeGql(client, QUERY_GET_MODEL, variables, T)

    return handleQuery(response, "models", label)
end

function getModels(client)
    response = executeGql(client, QUERY_GET_MODELS_ALL, Dict(), Vector{NvaNode{Model}})
    return handleQuery(response, "models")
end

function addModel!(client::NavAbilityClient, label::Symbol, model = nothing; modelKwargs...)
    input = [
        ModelCreateInput(;
            id = getId(client.id, label),
            label,
            org = createConnect(client.id),
            getCommonProperties(ModelCreateInput, model)...,
            getCommonProperties(ModelCreateInput, modelKwargs)...,
        ),
    ]

    variables = (input = input,)

    T = @NamedTuple{models::Vector{NvaNode{Model}}}

    response = executeGql(client, GQL_ADD_MODELS, variables, T)

    return handleMutate(response, "addModels", :models)[1]
end

function getGraphs(client::NavAbilityClient, model::NvaNode{Model})
    response = executeGql(
        client,
        QUERY_GET_MODEL_GRAPHS,
        Dict("id" => getId(model)),
        Vector{Dict{Symbol, Vector{NvaNode{Factorgraph}}}},
    )
    return handleQuery(response, "models")[1][:fgs]
end