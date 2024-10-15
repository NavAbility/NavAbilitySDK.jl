struct Org
    id::UUID#!
    label::Symbol#!
    description::String
    # models::Vector{Model}#!
    # agents::Vector{Agent}#!
    # fgs::Vector{Factorgraph}#!
    # users::Vector{Symbol}#!
end

# struct BlobStore end
struct Model end
struct Factorgraph end

struct NvaNode{T}
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

 
struct BlobStoreCreateInput
    id::UUID#!
    label::String#!
    # parent
    org::Any #OrgConnect
end
