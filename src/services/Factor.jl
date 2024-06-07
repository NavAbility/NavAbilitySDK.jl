#TODO factor does not have blobs yet

function addFactor!(
    fgclient::DFGClient,
    pacfac::PackedFactor;
    variableLabels::Vector{<:Union{Symbol, String}} = pacfac._variableOrderSymbols,
)
    client = fgclient.client

    # common field names
    fields = intersect(fieldnames(PackedFactor), fieldnames(FactorCreateInput))

    variables = Dict(
        "connect" => map(variableLabels) do vlink
            Dict(
                "where" => Dict(
                    "node" => Dict(
                        "userLabel" => fgclient.user.label,
                        "robotLabel" => fgclient.robot.label,
                        "sessionLabel" => fgclient.session.label,
                        # "sessionConnection" => Dict(
                        #     "node" => Dict("id" => fgclient.session.id),
                        # ),
                        "label" => vlink,
                    ),
                ),
            )
        end,
    )

    addfac = FactorCreateInput(;
        # uniqueKey = string(variableId, ".", vnd.solveKey),
        userLabel = fgclient.user.label,
        robotLabel = fgclient.robot.label,
        sessionLabel = fgclient.session.label,
        session = createConnect(fgclient.session.id),
        variables,
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
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "fields_summary" => true,
        "fields_full" => true,
    )

    T = Vector{
        Dict{String, Vector{Dict{String, Vector{Dict{String, Vector{PackedFactor}}}}}},
    }

    response =
        GQL.execute(client, GQL_GET_FACTORS, T; variables, throw_on_execution_error = true)

    return response.data["users"][1]["robots"][1]["sessions"][1]["factors"]
end


function getFactorsSkeleton(fgclient::DFGClient)
    client = fgclient.client

    variables = Dict(
        "userId" => fgclient.user.id,
        "robotId" => fgclient.robot.id,
        "sessionId" => fgclient.session.id,
        "fields_summary" => false,
        "fields_full" => false,
    )

    T = Vector{
        Dict{String, Vector{Dict{String, Vector{Dict{String, Vector{DFG.SkeletonDFGFactor}}}}}},
    }

    response =
        GQL.execute(client, GQL_GET_FACTORS, T; variables, throw_on_execution_error = true)

    return response.data["users"][1]["robots"][1]["sessions"][1]["factors"]
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
        # Vector{PackedFactor};
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

    T = Vector{
        Dict{
            String,
            Vector{
                Dict{
                    String,
                    Vector{Dict{String, Vector{NamedTuple{(:label,), Tuple{Symbol}}}}},
                },
            },
        },
    }

    response = GQL.execute(
        fgclient.client,
        GQL_LISTFACTORS,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return last.(response.data["users"][1]["robots"][1]["sessions"][1]["factors"])
end

# delete factor and its satelites (by factor id)
function deleteFactor!(fgclient::DFGClient, factor::DFG.AbstractDFGFactor)
    isnothing(factor.id) && error("Factor $(factor.label) does not have an id")

    variables = Dict("factorId" => factor.id)

    response = GQL.execute(
        fgclient.client,
        GQL_DELETE_FACTOR;
        variables,
        throw_on_execution_error = true,
    )

    return response.data
end