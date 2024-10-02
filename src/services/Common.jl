# type builder for JSON3 deserialization of chain of 
# user[] - robot[] - session[] - variable - T[]
function user_robot_session_variable_T(T)
    Vector{
        Dict{
            String,
            Vector{Dict{String, Vector{Dict{String, Vector{Dict{String, Vector{T}}}}}}},
        },
    }
end

# exists(client, context, label::Symbol) = 
function getCommonProperties(::Type{T}, from::F) where {T, F}
    commonfields = intersect(fieldnames(T), fieldnames(F))
    return (k => getproperty(from, k) for k in commonfields)
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

#TODO wip
getId(ns::UUID, labels...) = uuid5(ns, string(labels...))

function getId(node::Union{NvaFactorGraph, NvaAgent, NvaModel, NvaBlobStore}, labels...)
    namespace = node.namespace
    return getId(namespace, node.label, labels...)
end
#TODO consolidate further
getId(fgclient::NavAbilityDFG, parent::NvaFactorGraph, label::Symbol) = getId(parent, label)
getId(fgclient::NavAbilityDFG, parent::NvaAgent, label::Symbol) = getId(parent, label)
getId(fgclient::NavAbilityDFG, parent::NvaModel, label::Symbol) = getId(parent, label)
getId(fgclient::NavAbilityDFG, parent::DFG.AbstractDFGVariable, label::Symbol) = getId(fgclient.fg, parent.label, label)
getId(fgclient::NavAbilityDFG, parent::DFG.AbstractDFGFactor, label::Symbol) = getId(fgclient.fg, parent.label, label)


function createConnect(id::UUID)
    # return Dict("connect" => Dict("where" => Dict("node" => Dict("id" => string(id)))))
    return (connect = (where = (node = (id = string(id),),),),)
end

createConnect(fgclient::NavAbilityDFG, parent::NvaFactorGraph) = (Factorgraph=createConnect(getId(parent)),)
createConnect(fgclient::NavAbilityDFG, parent::NvaAgent) = (Agent=createConnect(getId(parent)),)
createConnect(fgclient::NavAbilityDFG, parent::NvaModel) = (Model=createConnect(getId(parent)),)
createConnect(fgclient::NavAbilityDFG, parent::DFG.AbstractDFGVariable) = (Variable=createConnect(getId(fgclient.fg, parent.label)),)
createConnect(fgclient::NavAbilityDFG, parent::DFG.AbstractDFGFactor) = (Factor=createConnect(getId(fgclient.fg, parent.label)),)
