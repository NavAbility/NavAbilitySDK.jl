#TODO factor does not have blobs yet

function createInput(fgclient::NavAbilityDFG, factor::FactorDFG)
    factorCreateInput = StructUtils.make(Dict{Symbol, Any}, factor, DFG.DFGJSONStyle())

    pop!(factorCreateInput, :blobentries)
    pop!(factorCreateInput, :bloblets)

    factorLabel = factor.label

    facId = getId(fgclient.fg, factorLabel)

    push!(factorCreateInput, :id => facId)
    push!(factorCreateInput, :graph => createConnect(getId(fgclient.fg)))

    push!(
        factorCreateInput,
        :variables => createConnect(
            map(vl -> getId(fgclient, fgclient.fg, vl), collect(factor.variableorder)),
        ),
    )

    factor_connect = createConnect(facId)
    if !isempty(DFG.refBlobentries(factor))
        blobentyNodes = map(values(DFG.refBlobentries(factor))) do entry
            Dict(
                :node => NvaSDK.CreateInput(
                    getId(fgclient.fg, factorLabel, entry.label),
                    entry,
                    Dict(:parent => (Factor = factor_connect,)),
                ),
            )
        end
        blobentries = Dict(:create => blobentyNodes)
        push!(factorCreateInput, :blobentries => blobentries)
    end

    return factorCreateInput
end

function DFG.addFactor!(fgclient::NavAbilityDFG, factor::FactorDFG)
    # return addFactors!(fgclient, [factor])[1]
    response = executeGql(
        fgclient,
        GQL_ADD_FACTORS,
        Dict(:input => [createInput(fgclient, factor)]),
        @NamedTuple{factors::Vector{FactorDFG}}
    )
    return handleMutate(response, :addFactors, :factors)[1]
end

function DFG.addFactors!(
    fgclient::NavAbilityDFG,
    factors::Vector{FactorDFG};
    chunksize::Int = 10,
    showprogress::Bool = length(factors) > 1000
)
    addfactors = map(factors) do factor
        createInput(fgclient, factor)
    end

    newfacs = @showprogress enabled = showprogress asyncmap(Iterators.partition(addfactors, chunksize)) do chunk
        response = executeGql(
            fgclient,
            GQL_ADD_FACTORS,
            Dict(:input => chunk),
            @NamedTuple{factors::Vector{FactorDFG}}
        )
        handleMutate(response, :addFactors, :factors)
    end

    return reduce(vcat, newfacs)
end

function DFG.getFactors(fgclient::NavAbilityDFG)
    fgId = getId(fgclient.fg)

    variables = Dict(:fgId => fgId, :fields_summary => true, :fields_full => true)

    T = Vector{Dict{Symbol, Vector{FactorDFG}}}

    response = executeGql(fgclient, GQL_GET_FACTORS, variables, T)

    return handleQuery(response, :graphs, fgclient.fg.label)[:factors]
end

function DFG.getFactorsSkeleton(fgclient::NavAbilityDFG)
    fgId = getId(fgclient.fg)

    variables = Dict(:fgId => fgId, :fields_summary => false, :fields_full => false)

    T = Vector{Dict{Symbol, Vector{DFG.FactorSkeleton}}}

    response = executeGql(fgclient, GQL_GET_FACTORS, variables, T)

    return handleQuery(response, :graphs, fgclient.fg.label)[:factors]
end

function DFG.getFactor(
    fgclient::NavAbilityDFG{<:AbstractGraphVariable, FT},
    label::Symbol,
) where {FT}
    namespace = fgclient.fg.namespace
    facId = NvaSDK.getId(namespace, fgclient.fg.label, label)

    variables = Dict(
        :facId => facId, 
        :fields_summary => true,
        :fields_full => true
    )

    response = executeGql(fgclient, GQL_GET_FACTOR, variables, Vector{FT};)
    return handleQuery(response, :factors, label)
end

function DFG.listFactors(
    fgclient::NavAbilityDFG,
    regexFilter::Union{Nothing, Regex} = nothing;
    tags::Vector{Symbol} = Symbol[], #FIXME tags should be tagsFilter
    solvableFilter::Union{Nothing, Base.Fix2} = nothing 
)
    fgId = NvaSDK.getId(fgclient.fg)
    variables =
        Dict(:fgId => fgId, :where => Dict{Symbol, Any}())

    if !isempty(tags)
        variables[:where][:tags] = Dict(:in => string.(tags))
    end

    if !isnothing(solvableFilter)
        solvableWhere = Dict{Symbol, Any}()
        if solvableFilter.f == >=
            solvableWhere[:gte] = solvableFilter.x
        elseif solvableFilter.f == >
            solvableWhere[:gt] = solvableFilter.x
        elseif solvableFilter.f == <=
            solvableWhere[:lte] = solvableFilter.x
        elseif solvableFilter.f == <
            solvableWhere[:lt] = solvableFilter.x
        elseif solvableFilter.f == ==
            solvableWhere[:eq] = solvableFilter.x
        elseif solvableFilter.f == in
            solvableWhere[:in] = solvableFilter.x
        else
            error("Unsupported solvableFilter function: $(solvableFilter.f)")
        end
        variables[:where][:solvable] = solvableWhere
    end

    response = executeGql(fgclient, GQL_LIST_FACTORS, variables, Vector{Symbol})
    labels = handleQuery(response, :listFactors)

    !isnothing(regexFilter) && filter!(x -> occursin(regexFilter, string(x)), labels)

    return labels
end

function DFG.deleteFactor!(fgclient::NavAbilityDFG, label::Symbol)
    facId = getId(fgclient.fg, label)
    variables = (factorId = facId,)
    response = executeGql(fgclient.client.client, GQL_DELETE_FACTOR, variables)
    return response[:deleteFactors][:nodesDeleted]
end

function DFG.getFactorBloblets(fgclient::NavAbilityDFG, label::Symbol)
    variables = (id = NvaSDK.getId(fgclient.fg, label),)

    T = Vector{@NamedTuple{bloblets::Vector{DFG.Bloblet}}}
    response = executeGql(fgclient, QUERY_GET_FACTOR_BLOBLETS, variables, T)

    return handleQuery(response, :factors, label).bloblets
end

function DFG.addFactorBloblet!(
    fgclient::NavAbilityDFG,
    label::Symbol,
    bloblet::DFG.Bloblet
)
    response = executeGql(
        fgclient,
        QUERY_ADD_FACTOR_BLOBLET,
        (
            id = NvaSDK.getId(fgclient.fg, label), 
            label = bloblet.label,
            val = bloblet.val
        ),
    )
    #TODO handle response
    return bloblet
end
