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

function createConnect(id::UUID)
    return Dict("connect" => Dict("where" => Dict("node" => Dict("id" => string(id)))))
end

function createVariableConnect(
    userLabel::String,
    robotLabel::String,
    sessionLabel::String,
    label::Symbol,
)
    return Dict(
        "connect" => Dict(
            "where" => Dict(
                "node" => Dict(
                    "label" => string(label),
                    "sessionLabel" => string(sessionLabel),
                    "robotLabel" => string(robotLabel),
                    "userLabel" => string(userLabel),
                ),
            ),
        ),
    )
    # variable": {"connect": { "where": {"node": {"label": "x0", "robotLabel": "IntegrationRobot", "userLabel": 
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

function getId(node::Union{FactorGraphRemote, AgentRemote, ModelRemote, BlobStoreRemote}, labels...)
    namespace = node.namespace
    return getId(namespace, node.label, labels...)
end
#TODO consolidate further
getId(fgclient::DFGClient, parent::FactorGraphRemote, label::Symbol) = getId(parent, label)
getId(fgclient::DFGClient, parent::AgentRemote, label::Symbol) = getId(parent, label)
getId(fgclient::DFGClient, parent::ModelRemote, label::Symbol) = getId(parent, label)
getId(fgclient::DFGClient, parent::DFG.AbstractDFGVariable, label::Symbol) = getId(fgclient.fg, parent.label, label)
getId(fgclient::DFGClient, parent::DFG.AbstractDFGFactor, label::Symbol) = getId(fgclient.fg, parent.label, label)
