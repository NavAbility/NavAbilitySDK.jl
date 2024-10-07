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
  navAbilityClient (NavAbilityClient): The NavAbility client.
  userLabel (String): The userLabel with access to the data.
  blobId (String): The unique file identifier of the data blob.
"""
# function createDownload(client::GQL.Client, userLabel::AbstractString, blobId::UUID)
function createDownload(store::NavAbilityBlobStore, blobId::UUID)
    type = "NVA_CLOUD"
    response = GQL.mutate(
        store.client.client,
        "createDownload",
        Dict("store"=>(label=store.label, type=type), "blobId"=>string(blobId));
        throw_on_execution_error = true,
    )
    return response.data["createDownload"]
end

function getBlob(blobstore::NavAbilityBlobStore, blobId::UUID)
    url = createDownload(blobstore, blobId)
    io = PipeBuffer()
    Downloads.download(url, io)
    return io |> take!
end

function getBlob(blobstore::NavAbilityCachedBlobStore, blobId::UUID)
    if hasBlob(blobstore.localstore, blobId)
        blob = getBlob(blobstore.localstore, blobId)
    else
        @info "missed in cache, caching" blobId
        blob = getBlob(blobstore.remotestore, blobId)
        addBlob!(blobstore.localstore, blobId, blob)
    end
    return blob
end

function DFG.listBlobs(store::NavAbilityBlobStore)
    query_args = Dict("store"=>(label=store.label,))
    response = GQL.query(
        store.client.client,
        "listBlobs",
        Vector{String};
        # output_fields = ["id"],
        query_args,
        throw_on_execution_error = true,
    )
    list = response.data["listBlobs"]
    # FIXME should only return uuid strings
    return UUID.(last.(split.(list, '/')))
end

function DFG.hasBlob(store::NavAbilityBlobStore, blobId::UUID)
    query_args = Dict("store"=>(label=store.label,), "blobId"=>string(blobId))
    response = GQL.query(
        store.client.client,
        "hasBlob",
        Bool;
        # output_fields = ["id"],
        query_args,
        throw_on_execution_error = true,
    )
    return response.data["hasBlob"]
end

listBlobsMeta(args...) = error("listBlobsMeta is deprecated, use BlobEntries")
listBlobsId(args...) = error("listBlobsId is deprecated, use listBlobs")


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
    response = GQL.execute(
        nvastore.client.client,
        GQL_CREATE_UPLOAD;
        variables = (blobId=blobId, parts=parts, store=store),
        throw_on_execution_error = true,
    )

    return response.data["createUpload"]
end

## Complete the upload

function completeUploadSingle(
    client::GQL.Client,
    blobId::UUID,
    uploadId::AbstractString,
    eTag::AbstractString,
)
    response = GQL.execute(
        client,
        GQL_COMPLETEUPLOAD_SINGLE;
        variables = Dict("blobId" => blobId, "uploadId" => uploadId, "eTag" => eTag),
        throw_on_execution_error = true,
    )

    return response.data["completeUpload"]
end

##

function addBlob!(
    store::NavAbilityBlobStore,
    blobId::UUID,
    blob::Vector{UInt8},
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
    res = completeUploadSingle(client.client, blobId, uploadId, eTag)

    res == "Accepted" ? nothing : @error("Unable to upload blob, $res")

    return UUID(blobId)
end

function addBlob!(
    blobstore::NavAbilityCachedBlobStore,
    blob::Vector{UInt8},
    filename::String,
)
    safefilename = split(filename,"/")[end]
    blobId = addBlob!(blobstore.remotestore, blob, String(safefilename))
    addBlob!(blobstore.localstore, blobId, blob, filename)
    return blobId
end

function DFG.deleteBlob!(
    blobstore::NavAbilityBlobStore,
    blobId::UUID
)
    response = GQL.mutate(
        blobstore.client,
        "deleteBlob",
        Dict("blobId" => string(blobId));
        throw_on_execution_error = true,
    )
    return response.data["deleteBlob"]

end

##==========================================================================================
## NavAbility™ Blob Store Deployed on Premise
##==========================================================================================

struct NavAbilityOnPremBlobStore <: DFG.AbstractBlobStore{Vector{UInt8}}
    client::NvaSDK.GQL.Client
    label::Symbol
end

function NavAbilityOnPremBlobStore(fgclient::NavAbilityDFG, label=:default)
    NavAbilityOnPremBlobStore(fgclient.client, label)
end

function DFG.addBlob!(store::NavAbilityOnPremBlobStore, blobId::UUID, blob::Vector{UInt8})
    b64blob = base64encode(blob)
    response = NvaSDK.GQL.mutate(
        store.client,
        "addBlob",
        Dict("blobId" => string(blobId), "input" => b64blob);
        throw_on_execution_error = true,
    )
    blobId_str = response.data["addBlob"]
    blobId = tryparse(UUID, blobId_str)
    isnothing(blobId) && error(blobId_str)
    return blobId
end

function DFG.getBlob(store::NavAbilityOnPremBlobStore, blobId::UUID)
    response = GQL.query(
        store.client,
        "getBlob";
        query_args = Dict("blobId" => string(blobId)),
        throw_on_execution_error = true,
    )
    return base64decode(response.data["getBlob"])
end