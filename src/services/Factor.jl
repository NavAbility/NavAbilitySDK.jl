#TODO factor does not have blobs yet

function connectWhere(label::Symbol)
    return Dict("where" => Dict("node" => Dict("label" => string(label))))
end

connectWhere(id::UUID) = Dict("where" => Dict("node" => Dict("id" => string(id))))

function addFactor!(
    fgclient::DFGClient,
    pacfac::PackedFactor;
    variableIds::Vector{<:Union{Symbol, String}} = pacfac._variableOrderSymbols,
)
    client = fgclient.client

    # common field names
    fields = intersect(fieldnames(PackedFactor), fieldnames(FactorCreateInput))

    addfac = FactorCreateInput(;
        # uniqueKey = string(variableId, ".", vnd.solveKey),
        userLabel = fgclient.user.label,
        robotLabel = fgclient.robot.label,
        sessionLabel = fgclient.session.label,
        session = createConnect(fgclient.session.id),
        variables = Dict("connect" => connectWhere.(variableIds)),
        (key => getproperty(pacfac, key) for key in fields)...,
    )

    variables = Dict("factorsToCreate" => [addfac])

    response = GQL.execute(
        client,
        GQL_ADD_FACTORS,
        FactorResponse;
        variables,
        throw_on_execution_error = true,
    )

    return response.data["addFactors"].factors[1]
end

function getFactors(fgclient::DFGClient)
    client = fgclient.client

    variables = Dict(
        "sessionId" => fgclient.session.id,
        "fields_summary" => true,
        "fields_full" => true,
    )

    response = GQL.execute(
        client,
        GQL_GET_Factors,
        Vector{PackedFactor};
        variables,
        throw_on_execution_error = true,
    )
    return response.data["factors"][]
end

function getFactor(fgclient::DFGClient, label::Symbol)
    client = fgclient.client

    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "factorLabel" => string(label),
        "fields_summary" => true,
        "fields_full" => true,
    )

    response = GQL.execute(
        client,
        GQL_GET_FACTOR_FROM_USER;
        # Vector{PackedVariable};
        variables,
        throw_on_execution_error = true,
    )

    jstr = JSON3.write(response.data["users"][1]["robots"][1]["sessions"][1]["factors"][1])

    return JSON3.read(jstr, PackedFactor)
end

function listFactors(fgclient::DFGClient)
    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
    )

    response = GQL.execute(
        fgclient.client,
        GQL_LIST_FACTORS;
        variables,
        throw_on_execution_error = true,
    )

    return Symbol.(response.data["users"][1]["robots"][1]["sessions"][1]["factors"])
end
