
# exists(client, context, label::Symbol) = 
function getCommonProperties(::Type{T}, from::F, exclude = Symbol[]) where {T, F}
    commonfields = intersect(fieldnames(T), fieldnames(F))
    setdiff!(commonfields, exclude)
    return (k => getproperty(from, k) for k in commonfields)
end

#TODO update all GQL.execute calls to use this
function executeGql(cfg::NavAbilityDFG, query::AbstractString, variables,  T::Type = Any; kwargs...)
    executeGql(cfg.client, query, variables, T; kwargs...)
end

function executeGql(cfg::NavAbilityClient, query::AbstractString, variables,  T::Type = Any; kwargs...)
    executeGql(cfg.client, query, variables, T; kwargs...)
end

function executeGql(client::GQL.Client, query::AbstractString, variables,  T::Type = Any; throw_on_execution_error = true, kwargs...)
    return GQL.execute(
        client,
        query,
        T;
        variables,
        throw_on_execution_error,
    )
end

function handleQuery(response, nodeName::String, label::Symbol)
    res = isnothing(response.data) ? nothing : get(response.data, nodeName, nothing)
    if isnothing(res)
        #TODO # throw correct error
        error("Query '$nodeName' failed on $label")
    elseif isempty(res)
        throw(KeyError(label))
    else
        return res[1]
    end
end

function handleQuery(response, nodeName::String)
    res = isnothing(response.data) ? nothing : get(response.data, nodeName, nothing)
    if isnothing(res)
        #TODO # throw correct error
        error("Query '$nodeName'")
    else
        return res
    end
end

function handleMutate(response, mutation::String, return_node::Symbol)
    res = isnothing(response.data) ? nothing : get(response.data, mutation, nothing)
    if isnothing(res)
        if !isnothing(response.errors) && !isempty(response.errors)
            #TODO # throw correct error
            throw(response.errors[1])
        end
    else
        return res[return_node]
    end
end

"""
    getId
Get the deterministic identifier (uuid v5) for a node.
"""
DFG.getId(ns::UUID, labels::Symbol...) = uuid5(ns, string(labels...))
DFG.getId(client::NavAbilityClient, labels::Symbol...) = getId(client.id, labels...)
DFG.getId(node::NvaNode, labels::Symbol...) = getId(node.namespace, node.label, labels...)
DFG.getId(fgclient::Union{NavAbilityDFG, NavAbilityClient}, parent::NvaNode, label::Symbol) = getId(parent, label)
DFG.getId(fgclient::NavAbilityDFG, parent::DFG.DFGNode, labels::Symbol...) = getId(fgclient.fg, parent.label, labels...)

"""
    createConnect
Create a connection gql query to a node.
"""
createConnect(id::UUID) = (connect = (where = (node = (id = string(id),),),),)
createConnect(ids::Vector{UUID}) = (connect = map(id->(where = (node = (id = string(id),),),), ids),)

# Create Parent connections for BlobEntry
createConnect(fgclient, parent::NvaNode{Factorgraph}) = (Factorgraph=createConnect(getId(parent)),)
createConnect(fgclient, parent::NvaNode{Agent}) = (Agent=createConnect(getId(parent)),)
createConnect(fgclient, parent::NvaNode{Model}) = (Model=createConnect(getId(parent)),)
createConnect(fgclient::NavAbilityDFG, parent::DFG.AbstractDFGVariable) = (Variable=createConnect(getId(fgclient.fg, parent.label)),)
createConnect(fgclient::NavAbilityDFG, parent::DFG.AbstractDFGFactor) = (Factor=createConnect(getId(fgclient.fg, parent.label)),)
