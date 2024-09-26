function getModel(client::NavAbilityClient, label::Symbol)

    id = getId(client.id, label)
    variables = Dict("modelId" => id)

    T = Vector{ModelRemote}

    response = GQL.execute(
        client.client,
        QUERY_GET_MODEL,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return handleQuery(response, "models", label)
end


GQL_ADD_MODELS = GQL.gql"""
mutation createModels($input: [ModelCreateInput!]!) {
  createModels(input: $input) {
    models {
        label
        createdTimestamp
        namespace
    }
  }
}
"""

function addModel!(client::NavAbilityClient, label::Symbol, model=nothing; modelKwargs...)
    input = [
        ModelCreateInput(;
            id = getId(client.id, label),
            label,
            org = createConnect(client.id),
            getCommonProperties(ModelCreateInput, model)...,
            getCommonProperties(ModelCreateInput, modelKwargs)...,
        )
    ]

    variables = (input=input,)

    # AgentRemoteResponse
    T = @NamedTuple{models::Vector{ModelRemote}}

    response =
        GQL.execute(client.client, GQL_ADD_MODELS, T; variables, throw_on_execution_error = true)

    return handleMutate(response, "createModels", :models)[1]
end

## =======================================================================================
function getModels(client::GQL.Client)
    T = Vector{Model}

    response = GQL.execute(client, QUERY_GET_MODELS_ALL, T; throw_on_execution_error = true)

    return response.data["models"]
end

function getModel(client::GQL.Client, modelId::UUID)
    variables = Dict("modelId" => modelId)

    T = Vector{Model}

    response =
        GQL.execute(client, QUERY_GET_MODEL, T; variables, throw_on_execution_error = true)

    return response.data["models"][1]
end

GQL_LINK_SESSION_TO_MODEL = GQL.gql"""
mutation linkSessionModel($modelId: ID!, $sessionId: ID!) {
  updateModels(
    where: { id: $modelId }
    connect: { sessions: { where: { node: { id: $sessionId } } } }
  ) {
    info {
      nodesCreated
      nodesDeleted
      relationshipsCreated
      relationshipsDeleted
    }
  }
}
"""

function addModel!(client::GQL.Client, modelLabel::String; status = "", description = "")
    variables =
        Dict("label" => modelLabel, "status" => status, "description" => description)
    response = GQL.execute(
        client,
        GQL_ADD_MODEL;
        # T;
        variables,
        throw_on_execution_error = true,
    )
    return response.data["addModels"]["models"][1]
end

function addFactorGraph!(client::GQL.Client, model::ModelRemote, fg::FactorGraphRemote)
    variables = Dict("modelId" => modelId, "sessionId" => sessionId)

    response = GQL.execute(
        client,
        GQL_LINK_SESSION_TO_MODEL;
        variables,
        throw_on_execution_error = true,
    )

    return response.data["updateModels"]["info"]
end
