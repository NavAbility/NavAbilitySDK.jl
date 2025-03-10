
const UPLOAD_CHUNK_SIZE_HASH = 5*1024*1024

#TODO we can also extend the blobstore
struct NavAbilityBlobStore <: DFG.AbstractBlobStore{Vector{UInt8}}
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

struct NavAbilityCachedBlobStore{T <: DFG.AbstractBlobStore} <:
       DFG.AbstractBlobStore{Vector{UInt8}}
    key::Symbol
    localstore::T
    remotestore::NavAbilityBlobStore
end

function NavAbilityCachedBlobStore(localstore::DFG.AbstractBlobStore, remotestore::NavAbilityBlobStore)
    return NavAbilityCachedBlobStore(:default_nva_cached, localstore, remotestore)
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
    return response.data["createDownload"]
end

function DFG.getBlob(blobstore::NavAbilityBlobStore, blobId::UUID)
    url = createDownload(blobstore, blobId)
    io = PipeBuffer()
    Downloads.download(url, io)
    return io |> take!
end

function DFG.getBlob(blobstore::NavAbilityCachedBlobStore, blobId::UUID)
    if hasBlob(blobstore.localstore, blobId)
        blob = getBlob(blobstore.localstore, blobId)
    else
        @info "missed in cache, caching" blobId
        blob = getBlob(blobstore.remotestore, blobId)
        # note, cache not getting non-blobentry metadata since non-blobentry metadata is conveniece only
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
    list = response.data["listBlobs"]
    return UUID.(list)
end

function DFG.hasBlob(store::NavAbilityBlobStore, blobId::UUID)
    response = executeGql(
        store,
        QUERY_HAS_BLOB,
        (blobId = string(blobId), label = store.label),
        Bool;
    )
    return response.data["hasBlob"]
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
    store = (label=nvastore.label, type="NVA_CLOUD")
    response = executeGql(
        nvastore.client,
        GQL_CREATE_UPLOAD,
        (blobId=blobId, parts=parts, store=store)
    )

    return response.data["createUpload"]
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

    return response.data["completeUpload"]
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

    return response.data["completeUpload"]
end

##


function DFG.addBlob!(
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


function DFG.addBlob!(
    store::NavAbilityBlobStore,
    blobId::UUID,
    blob::Vector{UInt8};
    mimeType::String = "application/octet-stream",
)
    client = store.client

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
        "Content-Type" => mimeType,
        "Accept" => "application/json, text/plain, */*",
        "Accept-Encoding" => "gzip, deflate, br",
        "Sec-Fetch-Dest" => "empty",
        "Sec-Fetch-Mode" => "cors",
        "Sec-Fetch-Site" => "cross-site",
        "Sec-GPC" => 1,
        "Connection" => "keep-alive",
    ]
    #

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
    blob::Vector{UInt8};
    mimeType::String = "application/octet-stream",
)
    addBlob!(blobstore.remotestore, blobId, blob; mimeType)
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
    return response.data["deleteBlob"]

end

##==========================================================================================
## NavAbility™ Blob Store Deployed on Premise
##==========================================================================================
struct NavAbilityOnPremBlobStore <: DFG.AbstractBlobStore{Vector{UInt8}}
    client::NavAbilityClient
    label::Symbol
end

function NavAbilityOnPremBlobStore(fgclient::NavAbilityDFG, label=:default)
    NavAbilityOnPremBlobStore(fgclient.client, label)
end

function DFG.addBlob!(
    store::NavAbilityOnPremBlobStore, 
    blobId::UUID, 
    blob::Vector{UInt8};
    mimeType::String = "application/octet-stream",
)
    b64blob = base64encode(blob)
    response = NvaSDK.GQL.mutate(
        store.client.client,
        "addBlobFS",
        Dict("storeLabel" => string(store.label), "blobId" => string(blobId), "input" => b64blob);
        throw_on_execution_error = true,
    )
    blobId_str = response.data["addBlobFS"]
    blobId = tryparse(UUID, blobId_str)
    isnothing(blobId) && error(blobId_str)
    return blobId
end

function DFG.getBlob(store::NavAbilityOnPremBlobStore, blobId::UUID)
    
    response = executeGql(
        store.client,
        QUERY_GET_BLOB,
        (id = string(blobId), storeLabel = string(store.label))
    )

    return base64decode(response.data["getBlob"])
end