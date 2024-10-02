#TODO factor does not have blobs yet

function addFactor!(
    fgclient::NavAbilityDFG,
    pacfac::PackedFactor;
    variableLabels::Vector{<:Union{Symbol, String}} = pacfac._variableOrderSymbols,
)
    client = fgclient.client.client

    factorLabel = pacfac.label

    namespace = fgclient.fg.namespace
    fgLabel = fgclient.fg.label
    fgId = NvaSDK.getId(namespace, fgLabel)

    variablesConnect = Dict(
        "connect" => map(variableLabels) do vlink
            Dict(
                "where" => Dict(
                    "node" => Dict(
                        "id" => getId(namespace, fgLabel, vlink),
                    ),
                ),
            )
        end,
    )

    addfac = FactorCreateInput(;
        getCommonProperties(FactorCreateInput, pacfac)...,
        variables=variablesConnect,
        id = getId(namespace, fgLabel, factorLabel),
        fg = createConnect(fgId),
    )

    variables = Dict("factorsToCreate" => [addfac])
    
    T = @NamedTuple{factors::Vector{PackedFactor}}

    response = GQL.execute(
        client,
        GQL_ADD_FACTORS,
        T;#FIXME: use factor response named tuple
        # FactorResponse;
        variables,
        throw_on_execution_error = true,
    )

    return handleMutate(response, "createFactors", :factors)[1]
end

function getFactors(fgclient::NavAbilityDFG)

    fgId = getId(fgclient.fg)

    variables = Dict(
        "fgId" => fgId,
        "fields_summary" => true,
        "fields_full" => true,
    )

    T = Vector{Dict{String, Vector{PackedFactor}}}

    response =
        GQL.execute(fgclient.client.client, GQL_GET_FACTORS, T; variables, throw_on_execution_error = true)

    return handleQuery(response, "factorgraphs", fgclient.fg.label)["factors"]
end


function getFactorsSkeleton(fgclient::NavAbilityDFG)
    fgId = getId(fgclient.fg)

    variables = Dict(
        "fgId" => fgId,
        "fields_summary" => false,
        "fields_full" => false,
    )

    T = Vector{Dict{String, Vector{DFG.SkeletonDFGFactor}}}

    response =
        GQL.execute(fgclient.client.client, GQL_GET_FACTORS, T; variables, throw_on_execution_error = true)

    return handleQuery(response, "factorgraphs", fgclient.fg.label)["factors"]
end

function getFactor(fgclient::NavAbilityDFG{<:AbstractDFGVariable, FT}, label::Symbol) where FT
    
    namespace = fgclient.fg.namespace
    facId = NvaSDK.getId(namespace, fgclient.fg.label, label)

    variables = Dict(
        "facId" => facId,
        "fields_summary" => true,
        "fields_full" => true,
    )

    response = GQL.execute(
        fgclient.client.client,
        GQL_GET_FACTOR,
        Vector{PackedFactor};
        variables,
        throw_on_execution_error = true,
    )
    #FIXME FT
    # return FT(handleQuery(response, "factors", label))
    return handleQuery(response, "factors", label)
end

function listFactors(fgclient::NavAbilityDFG)

    fgId = getId(fgclient.fg)

    variables = Dict(
        "fgId" => fgId
    )

    T = Vector{Dict{String, Vector{@NamedTuple{label::Symbol}}}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_LISTFACTORS,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return last.(handleQuery(response, "factorgraphs", fgclient.fg.label)["factors"])
end

# delete factor and its satelites (by factor id)
function deleteFactor!(fgclient::NavAbilityDFG, factor::DFG.AbstractDFGFactor)
    facId = getId(fgclient.fg, factor.label)

    variables = (factorId=facId,)

    response = GQL.execute(
        fgclient.client.client,
        GQL_DELETE_FACTOR;
        variables,
        throw_on_execution_error = true,
    )

    #TODO check if factor was deleted in response

    return factor
end

function deleteFactor!(fgclient::NavAbilityDFG, label::Symbol)
    f = getFactor(fgclient, label)
    return deleteFactor!(fgclient, f)
end