function getModel(client::NavAbilityClient, label::Symbol)
    response = executeGql(
        client,
        GQL_OPS[:getModel],
        (id = getId(client.id, label),),
        Vector{NvaNode{Model}}
    )
    return handleQuery(response, :models, label)
end

function getModels(client)
    response = executeGql(client, GQL_OPS[:getModels], Dict(), Vector{NvaNode{Model}})
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
        GQL_OPS[:addModels],
        (input = input,),
        @NamedTuple{models::Vector{NvaNode{Model}}}
    )

    return handleMutate(response, :addModels, :models)[1]
end

function getGraphs(client::NavAbilityClient, model::NvaNode{Model})
    response = executeGql(
        client,
        GQL_OPS[:getGraphs_Model],
        (id = getId(model),),
        Vector{Dict{Symbol, Vector{NvaNode{Graphroot}}}},
    )
    return handleQuery(response, :models)[1][:graphs]
end
