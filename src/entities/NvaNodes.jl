struct Org
    id::UUID#!
    label::Symbol#!
    description::String
    # models::Vector{Model}#!
    # agents::Vector{Agent}#!
    # fgs::Vector{Graphroot}#!
    # users::Vector{Symbol}#!
end

# struct BlobStore end
@kwdef struct Model
    label::Symbol
end

struct NvaNode{T}
    namespace::UUID
    label::Symbol
end

DFG.getLabel(node::NvaNode) = node.label

@kwdef struct AgentCreateInput
    # Interface
    id::UUID#!
    label::Symbol#!
    description::String = ""
    tags::Set{Symbol} = Set{Symbol}()#!
    # TODO bloblets
    version::VersionNumber = DFG.version(DFG.Agent)#!
    # parent
    org::Any #OrgConnect#!
    # children
    # blobentries::Any = nothing  #TODO VariableBlobentriesFieldInput
    # models::Vector{Model}#!
    # fgs::Vector{Graphroot}#!
end

JSON.omit_empty(::Type{<:AgentCreateInput}) = true

@kwdef struct ModelCreateInput
    id::UUID
    label::Symbol
    description::String = ""
    tags::Vector{Symbol} = Symbol[]
    # status::String
    # parent
    org::Any #OrgConnect#!
    # children
    blobentries::Any = nothing #TODO VariableBlobentriesFieldInput
    bloblets::Any = nothing #TODO VariableBlobletsFieldInput
    # models::Vector{Symbol}
end

JSON.omit_null(::Type{<:ModelCreateInput}) = true

@kwdef struct GraphCreateInput
    # Interface
    id::UUID#!
    label::Symbol#!
    description::String = ""
    tags::Set{Symbol} = Set{Symbol}()#!
    version::VersionNumber = DFG.version(DFG.Graphroot)#!
    # parent
    org::Any #OrgConnect
    # relationships
    # agents::Vector{Symbol}#!
    # #children
    # variables::Vector{Variable}#!
    # factors::Vector{Factor}#!
    # bloblets
    # agents::Any = nothing # AgentsConnect
    # blobentries::Any = nothing #TODO VariableBlobentriesFieldInput
end

JSON.omit_empty(::Type{<:GraphCreateInput}) = true

struct BlobStoreCreateInput
    id::UUID#!
    label::String#!
    # parent
    org::Any #OrgConnect
end
