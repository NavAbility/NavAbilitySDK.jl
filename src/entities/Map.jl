

Base.@kwdef struct Map
    id::Union{Nothing, UUID} = nothing
    label::String
    description::Union{Nothing, String} = ""
    status::String
    data::String
    thumbnailId::Union{Nothing, UUID}=nothing
    exportedMapId::Union{Nothing, UUID}=nothing
    annotations::Vector{Any}#TODO Annotation}
    affordances::Vector{Any}#TODO Affordance}
    workflows::Vector{Any}#TODO Workflow}
    sessions::Vector{Session}
    visualization::Union{Nothing,Any} #VisualizationBlob}}
    createdTimestamp::Union{Nothing,DateTime}
    lastUpdatedTimestamp::Union{Nothing,DateTime}
end


# class Workflow:
#     id: Optional[UUID]
#     label: str
#     description: Optional[str]
#     status: str
#     _type: str
#     data: Optional[str]
#     result: Optional[str]
#     createdTimestamp: Optional[datetime]
#     lastUpdatedTimestamp: Optional[datetime]
#     _version: str = payload_version


# class VisualizationBlob:
#     hierarchyId: UUID
#     octreeId: UUID
#     metadataId: UUID
