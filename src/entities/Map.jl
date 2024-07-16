

Base.@kwdef struct Map
    id::Union{Nothing, UUID} = nothing
    label::String
    description::Union{Nothing, String} = ""
    status::String
    data::Union{Nothing, String} = ""
    thumbnailId::Union{Nothing, UUID}=nothing
    exportedMapId::Union{Nothing, UUID}=nothing
    sessions::Vector{Session}
    createdTimestamp::Union{Nothing,ZonedDateTime}
    lastUpdatedTimestamp::Union{Nothing,ZonedDateTime}
    blobEntries::Vector{BlobEntry}
end

