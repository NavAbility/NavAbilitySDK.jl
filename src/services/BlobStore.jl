
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
        addBlob!(blobstore.localstore, blobId, blob)
    end
    return blob
end

#FIXME use executeGql
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

#FIXME use executeGql
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

function completeUpload(
    client::GQL.Client,
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

    response = GQL.execute(
        client,
        GQL_COMPLETEUPLOAD;
        variables = Dict(
            "blobId" => blobId, 
            "completedUpload" => cui, 
        ),
        throw_on_execution_error = true,
    )

    return response.data["completeUpload"]
end

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


function DFG.addBlob!(
    store::NavAbilityBlobStore,
    filepath::AbstractString,
    blobId::UUID = uuid4();
    chunkSize::Integer = UPLOAD_CHUNK_SIZE_HASH,
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
        # "Content-Length" => filesize,
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
        store.client.client,
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

function DFG.addBlob!(
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
    NavAbilityOnPremBlobStore(fgclient.client.client, label)
end

function DFG.addBlob!(store::NavAbilityOnPremBlobStore, blobId::UUID, blob::Vector{UInt8})
    b64blob = base64encode(blob)
    response = NvaSDK.GQL.mutate(
        store.client,
        "addBlobFS",
        Dict("storeLabel" => string(store.label), "blobId" => string(blobId), "input" => b64blob);
        throw_on_execution_error = true,
    )
    blobId_str = response.data["addBlobFS"]
    blobId = tryparse(UUID, blobId_str)
    isnothing(blobId) && error(blobId_str)
    return blobId
end

GQL_GET_BLOB = GQL.gql"""
query getBlob($id: String!, $storeLabel: String = "default") {
    getBlob(blobId: $id, storeLabel: $storeLabel)
}
"""

function DFG.getBlob(store::NavAbilityOnPremBlobStore, blobId::UUID)
    
    response = executeGql(
        store.client,
        GQL_GET_BLOB,
        (id = string(blobId), storeLabel = string(store.label))
    )

    return base64decode(response.data["getBlob"])
end