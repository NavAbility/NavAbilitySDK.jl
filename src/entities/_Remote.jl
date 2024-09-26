struct Org
    id::UUID#!
    label::String#!
    description::String
    # models::Vector{Model}#!
    # agents::Vector{Agent}#!
    # fgs::Vector{Factorgraph}#!
    # users::Vector{Symbol}#!
end
  
"""
    AgentRemote
A struct representing a reference to an Agent.
#TODO Naming
"""
@kwdef struct AgentRemote
    # Interface
    # id::UUID#!
    label::Symbol#!

    # metadata::String
    # tags::Vector{String}#! #"For exampl ['Robot', 'SensorHat'], ['Worker'] etc"
    # maybe type:String -> "Robot"/"Worker"
    # _version::String#!
    createdTimestamp::ZonedDateTime#!
    # lastUpdatedTimestamp::DateTime#!
    # parent
    namespace::UUID
    # org::Org#!
    # children
    # blobEntries::Vector{BlobEntry}#!
    # models::Vector{Model}#!
    # fgs::Vector{Factorgraph}#!
end

# @kwdef struct Agent
#     label::String#!
#     metadata::String
#     tags::Vector{String}#! #"For exampl ['Robot', 'SensorHat'], ['Worker'] etc"
#     # maybe type:String -> "Robot"/"Worker"
#     _version::String = string(DFG._getDFGVersion())#!
#     # parent
#     # org::Org#!
#     # children
#     # blobEntries::Vector{BlobEntry}#!
#     # models::Vector{Model}#!
#     # fgs::Vector{Factorgraph}#!
# end

@kwdef struct AgentCreateInput
    # Interface
    id::UUID#!
    label::Symbol#!
    metadata::String = "e30="
    # description::String #FIXME
    tags::Vector{Symbol} = Symbol[]#!
    _version::String = string(DFG._getDFGVersion())#!
    # parent
    org::Any #OrgConnect#!
    # children
    blobEntries::Any = nothing #TODO VariableBlobEntriesFieldInput
    # models::Vector{Model}#!
    # fgs::Vector{Factorgraph}#!
end

StructTypes.omitempties(::Type{AgentCreateInput}) = (:blobEntries,)


"""
    ModelRemote
A struct representing a reference to a Model.
Models are representations of some subject matter, such as a map, a car, a city, a supply chain, or a factory and its surroundings.
#TODO Naming
"""
@kwdef struct ModelRemote
    label::Symbol
    # description::Union{Nothing, String} = ""
    # metadata::Union{Nothing, String} = ""
    # tags::Vector{Symbol} = Symbol[]
    createdTimestamp::Union{Nothing,ZonedDateTime}
    # lastUpdatedTimestamp::Union{Nothing,ZonedDateTime}
    # parent
    namespace::UUID
    # children
    # models::Vector{Symbol}
    # fgs::Vector{Symbol}
    # blobEntries::Vector{BlobEntry}
end

@kwdef struct ModelCreateInput
    id::UUID
    label::Symbol
    description::String = ""
    # status::String
    metadata::String = "e30="
    tags::Vector{Symbol} = Symbol[]
    # parent
    org::Any #OrgConnect#!
    # children
    blobEntries::Any = nothing #TODO VariableBlobEntriesFieldInput
    # models::Vector{Symbol}
end

StructTypes.omitempties(::Type{ModelCreateInput}) = (:blobEntries,)

"""
    FactorGraphRemote
A struct representing a reference to a Factor Graph.
#TODO Naming
"""
@kwdef struct FactorGraphRemote
    # id::UUID#!
    label::Symbol#!
    # description::String
    # metadata::String
    # _version::String
    createdTimestamp::ZonedDateTime
    # lastUpdatedTimestamp::DateTime
    # parent
    namespace::UUID 
    # relationships
    # agents::Vector{Symbol}#!
    # #children
    # variables::Vector{Variable}#!
    # factors::Vector{Factor}#!
    # blobEntries::Vector{BlobEntry}#!
    # # Derived fields
    # numVariables::Int 
    # numFactors::Int 
    # solveKeys::Vector{String} 
end

@kwdef struct FactorGraphCreateInput
    id::UUID#!
    label::Symbol#!
    description::String
    metadata::String
    _version::String
    # parent
    # namespace::UUID 
    # relationships
    # agents::Vector{Symbol}#!
    # #children
    # variables::Vector{Variable}#!
    # factors::Vector{Factor}#!
    # blobEntries::Vector{BlobEntry}#!
    org::Any #OrgConnect
    agents::Any = nothing # AgentsConnect
    blobEntries::Any = nothing #TODO VariableBlobEntriesFieldInput
end

struct BlobStoreRemote <: DFG.AbstractBlobStore{UInt8}
    # id::UUID#!
    namespace::UUID
    label::String#!
    createdTimestamp::DateTime#!
    # lastUpdatedTimestamp::DateTime#!
    # parent
    # org::Org#!
end
  
struct BlobStoreCreateInput
    id::UUID#!
    label::String#!
    # parent
    org::Any #OrgConnect
end

# FIXME DEPRECATED
struct Context end
Context(a...; ka...) = error("deprecated")


#TODO wip
getId(ns::UUID, labels...) = uuid5(ns, string(labels...))

function getId(node::Union{FactorGraphRemote, AgentRemote, ModelRemote, BlobStoreRemote}, labels...)
    namespace = node.namespace
    return getId(namespace, node.label, labels...)
end
