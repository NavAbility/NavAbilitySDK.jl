struct Org
    id::UUID#!
    label::Symbol#!
    description::String
    # models::Vector{Model}#!
    # agents::Vector{Agent}#!
    # fgs::Vector{Factorgraph}#!
    # users::Vector{Symbol}#!
end

#TODO consider using Remote{T}
# abstract type AbstractAgent end
# abstract type AbstractModel end
# abstract type AbstractFactorGraph end

# struct Remote{T}
#     namespace::UUID
#     label::Symbol
# end

"""
    NvaAgent
A struct representing a reference to an Agent.
#TODO Naming
"""
@kwdef struct NvaAgent
    namespace::UUID
    label::Symbol
end

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
    NvaModel
A struct representing a reference to a Model.
Models are representations of some subject matter, such as a map, a car, a city, a supply chain, or a factory and its surroundings.
#TODO Naming
"""
@kwdef struct NvaModel
    namespace::UUID
    label::Symbol
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
    NvaFactorGraph
A struct representing a reference to a Factor Graph.
#TODO Naming
"""
@kwdef struct NvaFactorGraph
    namespace::UUID 
    label::Symbol#!
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

struct NvaBlobStore <: DFG.AbstractBlobStore{UInt8}
    namespace::UUID
    label::String#!
end
  
struct BlobStoreCreateInput
    id::UUID#!
    label::String#!
    # parent
    org::Any #OrgConnect
end
