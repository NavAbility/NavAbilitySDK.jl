
StructUtils.@nonstruct struct CreateInput{T}
    id::UUID
    node::T
    connect::Dict{Symbol} #FIXME think Any is named tuple, but maybe ok
end

function StructUtils.lower(x::CreateInput)
    d = StructUtils.make(Dict{Symbol, Any}, x.node)
    merge!(d, x.connect)
    push!(d, :id => x.id)
    return d
end

JSON.omit_empty(::Type{<:CreateInput}) = true

# exists(client, context, label::Symbol) = 
function getCommonProperties(::Type{T}, from::F, exclude = Symbol[]) where {T, F}
    commonfields = intersect(fieldnames(T), fieldnames(F))
    setdiff!(commonfields, exclude)
    return (k => getproperty(from, k) for k in commonfields)
end

#TODO update all GQL.execute calls to use this
function executeGql(
    cfg::NavAbilityDFG,
    query::AbstractString,
    variables,
    T::Type = Any;
    kwargs...,
)
    executeGql(cfg.client, query, variables, T; kwargs...)
end

function executeGql(
    cfg::NavAbilityClient,
    query::AbstractString,
    variables,
    T::Type = Any;
    kwargs...,
)
    executeGql(cfg.client, query, variables, T; kwargs...)
end

function checkerrors(body)
    if :errors in propertynames(body) && length(body.errors) > 0
        # Parse constraint validation errors as LabelExistsError
        for err in JSON.parse(body.errors)
            msg = get(err, "message", "")
            if occursin(r"Constraint validation failed", msg)
                #TODO what type and what key, msg should be node, as example "[Variable] label `[a]` already exists"
                query = get(err, "path", ["node"])[1]
                throw(DFG.LabelExistsError("$query", Symbol("label unknown")))
            else
                error("Request to server failed with: ", msg)
            end
        end
    end
    return nothing
end

# Execution helper addapted for JSON.jl
function executeGql(
    client::GQL.Client,
    query::AbstractString,
    variables,
    ::Type{T} = Any;
    throw_on_execution_error = true,
    retries = 1,
    readtimeout = 0,
    operationName = nothing,
) where {T}
    endpoint = client.endpoint
    headers = merge(Dict("Content-Type" => "application/json"), client.headers)
    payload = JSON.json(
        (query = query, variables = variables, operationName = operationName);
        style = DFG.DFGJSONStyle(),
    )

    resp = HTTP.post(
        endpoint,
        headers,
        payload;
        retries,
        readtimeout,
        retry_non_idempotent = retries > 0,
    )

    body = JSON.lazy(String(resp.body))
    global g_body = body #FIXME debuging remove
    throw_on_execution_error && checkerrors(body)

    #TODO should we ever return errors or handle them here? maybe tuple?
    return JSON.parse(body.data, Dict{Symbol, T}; style = DFG.DFGJSONStyle())
end

# JSONv1 style
function handleQuery(response::Dict, nodeName::Symbol, label::Symbol)
    res = isnothing(response) ? nothing : get(response, nodeName, nothing)
    if isnothing(res)
        #TODO # Don't think this can happen? throw correct error
        error("Query '$nodeName' failed on $label")
    elseif isempty(res)
        throw(DFG.LabelNotFoundError(string(nodeName), label))
    else
        return res[1]
    end
end

function handleQuery(response::Dict, nodeName::Symbol)
    res = isnothing(response) ? nothing : get(response, nodeName, nothing)
    if isnothing(res)
        #TODO # throw correct error
        error("Query '$nodeName'")
    else
        return res
    end
end

function handleMutate(response::Dict, mutation::Symbol, return_node::Symbol)
    mutation = get(response, mutation, nothing)
    if isnothing(mutation)
        #TODO # throw correct error
        error("'$mutation' failed")
    else
        return mutation[return_node]
    end
end

"""
    getId

Get the deterministic identifier (uuid v5) for a node.
"""
DFG.getId(ns::UUID, labels::Symbol...) = uuid5(ns, string(labels...))
DFG.getId(client::NavAbilityClient, labels::Symbol...) = getId(client.id, labels...)
DFG.getId(node::NvaNode, labels::Symbol...) = getId(node.namespace, node.label, labels...)
function DFG.getId(
    fgclient::Union{NavAbilityDFG, NavAbilityClient},
    parent::NvaNode,
    label::Symbol,
)
    getId(parent, label)
end
#TODO confirm this one
function DFG.getId(
    fgclient::NavAbilityDFG,
    parent::DFG.AbstractGraphNode,
    labels::Symbol...,
)
    getId(fgclient.fg, parent.label, labels...)
end

"""
    createConnect

Create a connection gql query to a node.
"""
createConnect(id::UUID) = (connect = (where = (node = (id = (eq = string(id),),),),),)
function createConnect(ids::Vector{UUID})
    (connect = map(id -> (where = (node = (id = (eq = string(id),),),),), ids),)
end

# Create Parent connections for Blobentry
function createConnect(fgclient, parent::NvaNode{Graphroot})
    (Graph = createConnect(getId(parent)),)
end
createConnect(fgclient, parent::NvaNode{Agent}) = (Agent = createConnect(getId(parent)),)
createConnect(fgclient, parent::NvaNode{Model}) = (Model = createConnect(getId(parent)),)
function createConnect(fgclient::NavAbilityDFG, parent::DFG.AbstractGraphVariable)
    (Variable = createConnect(getId(fgclient.fg, parent.label)),)
end
function createConnect(fgclient::NavAbilityDFG, parent::DFG.AbstractGraphFactor)
    (Factor = createConnect(getId(fgclient.fg, parent.label)),)
end

# Common Filters
#TODO add to other nodes with label filters
#TODO test and add to nodes with numerical filters
function whereFilter(filt::Base.Fix2)
    if filt.f == startswith
        return (startsWith = filt.x, )
    elseif filt.f == contains
        return (contains = filt.x, )
    elseif filt.f == endswith
        return (endsWith = filt.x, )
    elseif filt.f == >=
        return (gte = filt.x,)
    elseif filt.f == >
        return (gt = filt.x,)
    elseif filt.f == <=
        return (lte = filt.x,)
    elseif filt.f == <
        return (lt = filt.x,)
    elseif filt.f == ==
        return (eq = filt.x,)
    elseif filt.f == in
        return (in = filt.x,)
    else
        error("Unsupported filter")
    end
end
