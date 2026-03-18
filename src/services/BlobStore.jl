
const UPLOAD_CHUNK_SIZE_HASH = 5*1024*1024

#TODO we can also extend the blobstore
struct NavAbilityBlobStore <: DFG.AbstractBlobstore{Vector{UInt8}}
    client::NavAbilityClient
    label::Symbol
end

NavAbilityBlobStore(client::NavAbilityClient) = NavAbilityBlobStore(client, :default)

NavAbilityBlobStore(client::GQL.Client, userLabel::String, label = :default) = 
    error("Deprecated, use NavAbilityBlobStore(client::NavAbilityClient, label::Symbol)")

function Base.show(io::IO, ::MIME"text/plain", s::NavAbilityBlobStore)
    summary(io, s)
    print(io, "\n ")
    show(io, MIME("text/plain"), s.client)
    println(io, "\n  label: ", s.label)
end

function NavAbilityBlobStore(fgclient::NavAbilityDFG, label::Symbol = :default)
    NavAbilityBlobStore(fgclient.client, label)
end

function executeGql(store::NavAbilityBlobStore, query::AbstractString, variables,  T::Type = Any; kwargs...)
    executeGql(store.client, query, variables, T; kwargs...)
end

struct NavAbilityCachedBlobStore{T <: DFG.AbstractBlobstore} <:
       DFG.AbstractBlobstore{Vector{UInt8}}
    label::Symbol
    localstore::T
    remotestore::NavAbilityBlobStore
end

function NavAbilityCachedBlobStore(localstore::DFG.AbstractBlobstore, remotestore::NavAbilityBlobStore)
    return NavAbilityCachedBlobStore(:default, localstore, remotestore)
end

"""
$(SIGNATURES)
Request URLs for data blob download.

Args:
  store (NavAbilityBlobStore): The NavAbility blob store.
  blobId (String): The unique file identifier of the data blob.
"""
function createDownload(store::NavAbilityBlobStore, blobId::UUID)
    response = executeGql(
        store.client,
        MUTATION_CREATE_DOWNLOAD,
        (blobId = string(blobId), label=store.label);
    )
    return response[:createDownload]
end

function DFG.getBlob(blobstore::NavAbilityBlobStore, blobId::UUID)
    try 
        url = createDownload(blobstore, blobId)
        #TODO throw if not found, so update createDownload to know when blobId is not found
        # throw(IdNotFoundError("Blob", blobId))
        io = PipeBuffer()
        Downloads.download(url, io)
        return io |> take!
    catch e
        if e isa Downloads.RequestError && e.response.status == 404
            throw(DFG.IdNotFoundError("Blob", blobId))
        else
            rethrow()
        end
    end
end

function DFG.getBlob(blobstore::NavAbilityCachedBlobStore, blobId::UUID)
    if hasBlob(blobstore.localstore, blobId)
        blob = getBlob(blobstore.localstore, blobId)
    else
        # @info "missed in cache, caching" blobId
        blob = getBlob(blobstore.remotestore, blobId)
        addBlob!(blobstore.localstore, blobId, blob)
    end
    return blob
end

function DFG.listBlobs(store::NavAbilityBlobStore)
    response = executeGql(
        store,
        QUERY_LIST_BLOBS,
        (label = store.label,),
        Vector{String},
    )
    return tryparse.(UUID, response[:listBlobs])
end

function DFG.hasBlob(store::NavAbilityBlobStore, blobId::UUID)
    response = executeGql(
        store,
        QUERY_HAS_BLOB,
        (blobId = string(blobId), label = store.label),
        Bool;
    )
    return response[:hasBlob]
end

## =========================================================================
## Upload
## =========================================================================

"""
$(SIGNATURES)
Request URLs for data blob upload.

Args:
  navAbilityClient (NavAbilityClient): The NavAbility client.
  blobId: The unique file identifier of the data blob.
  parts (Int): Split upload into multiple blob parts, FIXME currently only supports parts=1.
"""
function createUpload(
    nvastore::NavAbilityBlobStore,
    blobId::UUID,
    parts::Int = 1,
)
    #
    response = executeGql(
        nvastore.client,
        GQL_CREATE_UPLOAD,
        (blobId=blobId, parts=parts, store=(label=nvastore.label,))
    )

    return response[:createUpload]
end

## Complete the upload

function completeUpload(
    client::NavAbilityClient,
    blobId::UUID,
    uploadId::AbstractString,
    eTags::AbstractVector{<:AbstractString},
)
    # CompletedUploadPartInput 
    parts = Vector{Dict{String,Any}}()
    for (pn,eTag) in enumerate(eTags)
        push!(parts,
            Dict{String,Any}(
                "partNumber" => pn,
                "eTag" => eTag,
            )
        )
    end

    # CompletedUploadInput
    cui = Dict{String,Any}(
        "uploadId" => uploadId,
        "parts" => parts
    )

    response = executeGql(
        client,
        GQL_COMPLETEUPLOAD,
        (blobId = blobId, completedUpload = cui)
    )

    return response[:completeUpload]
end

function completeUploadSingle(
    client::NavAbilityClient,
    blobId::UUID,
    uploadId::AbstractString,
    eTag::AbstractString,
)
    response = executeGql(
        client,
        GQL_COMPLETEUPLOAD_SINGLE,
        (blobId = blobId, uploadId = uploadId, eTag = eTag),
    )

    return response[:completeUpload]
end

##


function uploadFile!(
    store::NavAbilityBlobStore,
    filepath::AbstractString,
    blobId::UUID = uuid4();
    chunkSize::Integer = UPLOAD_CHUNK_SIZE_HASH,
    mimeType::String = "application/octet-stream",
)
    # locate large file on fs, ready to read in chunks
    fid = open(filepath,"r")

    # calculate number or parts necessary
    nparts = ceil(Int, filesize(filepath) / chunkSize)

    # create the upload url destination
    crUp = createUpload(store, blobId, nparts)

    # recover uploadId for later completion
    uploadId = crUp["uploadId"]
    
    # custom header for pushing the file up
    headers_ = [
        "Content-Length" => filesize(filepath),
        "Content-Type" => mimeType,
        "Accept" => "application/json, text/plain, */*",
        "Accept-Encoding" => "gzip, deflate, br",
        "Sec-Fetch-Dest" => "empty",
        "Sec-Fetch-Mode" => "cors",
        "Sec-Fetch-Site" => "cross-site",
        "Sec-GPC" => 1,
        "Connection" => "keep-alive",
    ]
    
    # recover all the eTags for later completion of upload
    eTags = Vector{String}()
    for (np,url_) in enumerate(crUp["parts"])
        # recover nparts-many urls from API response
        url = url_["url"]
        # read chunk from file
        chunk = Vector{UInt8}()
        sz = readbytes!(fid,chunk,chunkSize)
        # upload each chunk with header CONTENT_LENGTH
        headers = vcat(
            "Content-Length" => sz,
            headers_
        )
        # recover eTag from each successful upload
        resp = HTTP.put(url, headers, chunk)
        # Extract eTag
        eTag = match(r"[a-zA-Z0-9]+", resp["eTag"]).match
        push!(eTags, eTag)
    end

    # close file
    close(fid)

    # close out the upload
    res = completeUpload(
        store.client,
        blobId,
        uploadId,
        eTags
    )

    res == "Accepted" ? nothing : @error("Unable to upload blob, $res")

    blobId
end

function getMimetype(io::IO)
    getFormat(s::DFG.FileIO.Stream{T}) where T = T
    stream = DFG.FileIO.query(io)
    # not sure if we need restrict to only our mimetypes, but better than nothing
    mime = findfirst(==(getFormat(stream)), DFG._MIMETypes)
    if isnothing(mime)
        return MIME("application/octet-stream")
    else
        return mime
    end
end

function DFG.addBlob!(store::NavAbilityBlobStore, blobId::UUID, blob::Vector{UInt8})
    client = store.client

    mimeType = getMimetype(IOBuffer(blob))
    filesize = length(blob)
    # TODO: Use about a 50M file part here.
    np = 1 # TODO: ceil(filesize / 50e6)
    # create the upload url destination
    d = createUpload(store, blobId, np)

    url = d["parts"][1]["url"]
    uploadId = d["uploadId"]

    # custom header for pushing the file up
    headers = [
        "Content-Length" => filesize,
        "Content-Type" => string(mimeType),
        "Accept" => "application/json, text/plain, */*",
        "Accept-Encoding" => "gzip, deflate, br",
        "Sec-Fetch-Dest" => "empty",
        "Sec-Fetch-Mode" => "cors",
        "Sec-Fetch-Site" => "cross-site",
        "Sec-GPC" => 1,
        "Connection" => "keep-alive",
    ]
    #

    #TODO use retries from new client field ; retries=getRetries(store)
    resp = HTTP.put(url, headers, blob)

    # Extract eTag
    eTag = match(r"[a-zA-Z0-9]+", resp["eTag"]).match

    # close out the upload
    res = completeUploadSingle(client, blobId, uploadId, eTag)

    res == "Accepted" ? nothing : @error("Unable to upload blob, $res")

    return UUID(blobId)
end

function DFG.addBlob!(
    blobstore::NavAbilityCachedBlobStore,
    blobId::UUID,
    blob::Vector{UInt8},
)
    addBlob!(blobstore.remotestore, blobId, blob)
    addBlob!(blobstore.localstore, blobId, blob)
    return blobId
end

function DFG.deleteBlob!(
    blobstore::NavAbilityBlobStore,
    blobId::UUID
)
    response = executeGql(
        blobstore.client,
        MUTATION_DELETE_BLOB,
        (blobId = string(blobId), label = string(blobstore.label));
    )
    return response[:deleteBlob]

end

function DFG.deleteBlob!(
    blobstore::NavAbilityCachedBlobStore,
    blobId::UUID,
)
    deleteBlob!(blobstore.remotestore, blobId)
    deleteBlob!(blobstore.localstore, blobId)
    return 1
end
