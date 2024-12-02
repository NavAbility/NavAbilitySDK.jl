#TODO factor does not have blobs yet

function DFG.addFactor!(fgclient::NavAbilityDFG, pacfac::FactorDFG)
    return addFactors!(fgclient, [pacfac])[1]
end

function DFG.addFactors!(
    fgclient::NavAbilityDFG,
    pacfactors::Vector{FactorDFG};
    chunksize::Int = 20,
)
    addfactors = map(pacfactors) do pacfac
        FactorCreateInput(;
            getCommonProperties(FactorCreateInput, pacfac)...,
            id = getId(fgclient, pacfac),
            variables = createConnect(
                map(vl -> getId(fgclient, fgclient.fg, vl), pacfac._variableOrderSymbols),
            ),
            fg = createConnect(getId(fgclient.fg)),
        )
    end

    T = @NamedTuple{factors::Vector{FactorDFG}}
    newfacs = @showprogress asyncmap(Iterators.partition(addfactors, chunksize)) do chunk
        response =
            executeGql(fgclient, GQL_ADD_FACTORS, Dict("factorsToCreate" => chunk), T)
        handleMutate(response, "addFactors", :factors)
    end

    return reduce(vcat, newfacs)
end

function DFG.getFactors(fgclient::NavAbilityDFG)
    fgId = getId(fgclient.fg)

    variables = Dict("fgId" => fgId, "fields_summary" => true, "fields_full" => true)

    T = Vector{Dict{String, Vector{FactorDFG}}}

    response = executeGql(fgclient, GQL_GET_FACTORS, variables, T)

    return handleQuery(response, "factorgraphs", fgclient.fg.label)["factors"]
end

function DFG.getFactorsSkeleton(fgclient::NavAbilityDFG)
    fgId = getId(fgclient.fg)

    variables = Dict("fgId" => fgId, "fields_summary" => false, "fields_full" => false)

    T = Vector{Dict{String, Vector{DFG.SkeletonDFGFactor}}}

    response = executeGql(fgclient, GQL_GET_FACTORS, variables, T)

    return handleQuery(response, "factorgraphs", fgclient.fg.label)["factors"]
end

function DFG.getFactor(
    fgclient::NavAbilityDFG{<:AbstractDFGVariable, FT},
    label::Symbol,
) where {FT}
    namespace = fgclient.fg.namespace
    facId = NvaSDK.getId(namespace, fgclient.fg.label, label)

    variables = Dict("facId" => facId, "fields_summary" => true, "fields_full" => true)

    response = executeGql(fgclient, GQL_GET_FACTOR, variables, Vector{FactorDFG};)
    return FT(handleQuery(response, "factors", label))
end

function DFG.listFactors(
    fgclient::NavAbilityDFG,
    regexFilter::Union{Nothing, Regex} = nothing;
    tags::Vector{Symbol} = Symbol[],
    solvable::Union{Int, Nothing} = nothing,
    solvableFilter::Union{Nothing, Base.Fix2} = isnothing(solvable) ? nothing :
                                                >=(solvable),
)
    fgId = NvaSDK.getId(fgclient.fg)
    variables =
        Dict("fgId" => fgId, "where" => Dict{String, Union{Int, Vector{Int}, Symbol}}())

    if !isempty(tags)
        @assert length(tags) == 1 "Only one tag is currently supported in tags filter"
        variables["where"]["tags_INCLUDES"] = tags[1]
    end

    if !isnothing(solvableFilter)
        if solvableFilter.f == >=
            variables["where"]["solvable_GTE"] = solvableFilter.x
        elseif solvableFilter.f == >
            variables["where"]["solvable_GT"] = solvableFilter.x
        elseif solvableFilter.f == <=
            variables["where"]["solvable_LTE"] = solvableFilter.x
        elseif solvableFilter.f == <
            variables["where"]["solvable_LT"] = solvableFilter.x
        elseif solvableFilter.f == ==
            variables["where"]["solvable"] = solvableFilter.x
        elseif solvableFilter.f == in
            variables["where"]["solvable_IN"] = solvableFilter.x
        else
            error("Unsupported solvableFilter function: $(solvableFilter.f)")
        end
    end

    response = executeGql(fgclient, GQL_LIST_FACTORS, variables, Vector{Symbol})
    labels = handleQuery(response, "listFactors")

    !isnothing(regexFilter) && filter!(x -> occursin(regexFilter, string(x)), labels)

    return labels
end

# delete factor and its satelites (by factor id)
function DFG.deleteFactor!(fgclient::NavAbilityDFG, factor::DFG.AbstractDFGFactor)
    facId = getId(fgclient.fg, factor.label)

    variables = (factorId = facId,)

    response = executeGql(fgclient.client.client, GQL_DELETE_FACTOR, variables)

    #TODO check if factor was deleted in response

    return factor
end

function DFG.deleteFactor!(fgclient::NavAbilityDFG, label::Symbol)
    f = getFactor(fgclient, label)
    return deleteFactor!(fgclient, f)
end