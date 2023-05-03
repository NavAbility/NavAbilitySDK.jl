
NavAbilityBlobStore(client::GQL.Client, userLabel::String) = NavAbilityBlobStore(:NAVABILITY, client, userLabel)

function Base.show(io::IO, ::MIME"text/plain", s::NavAbilityBlobStore)
    summary(io, s)
    print(io, "\n  ")
    show(io, MIME("text/plain"), s.client)
    println(io, "\n  User Name\n    ", s.userLabel)
end

function NavAbilityBlobStore(fgclient::DFGClient)
    NavAbilityBlobStore(:NAVABILITY, fgclient.client, fgclient.user.label)
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
function createDownload(client::GQL.Client, userLabel::AbstractString, blobId::UUID)
    response = GQL.mutate(
        client,
        "createDownload",
        Dict("userId" => userLabel, "blobId" => string(blobId));
        throw_on_execution_error = true,
    )
    #TODO API is a bit confusing as it is the user label that works here, ie. guest@navability.io
    return response.data["createDownload"]
    # data = get(response,"data",nothing)
    # if data === nothing || !haskey(data, "url") throw(KeyError("Cannot create download for $userLabel, requesting $blobId.\n$rootData")) end
    # urlMsg = get(data,"url","Error")
end

##
# function getBlob(client::GQL.Client, userLabel::AbstractString, blobId::UUID)
#     url = createDownload(client, userLabel, blobId)
#     io = PipeBuffer()
#     Downloads.download(url, io)
#     return io |> take!
# end

function getBlob(blobstore::NavAbilityBlobStore, blobId::UUID)
    url = createDownload(blobstore.client, blobstore.userLabel, blobId)
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

listBlobsId(blobstore::NavAbilityBlobStore, namecontains::String="") = 
    listBlobsId(blobstore.client, namecontains)

function listBlobsId(client::GQL.Client, namecontains::String="")
    query_args = Dict("where"=>Dict("name_CONTAINS"=>namecontains))
    response = GQL.query(
        client,
        "blobs",
        Vector{NamedTuple{(:id,), Tuple{UUID}}};
        output_fields = ["id"],
        query_args,
        throw_on_execution_error = true,
    )
    return last.(response.data["blobs"])
end

listBlobsMeta(blobstore::NavAbilityBlobStore, namecontains::String="") = 
    listBlobsMeta(blobstore.client, namecontains)

function listBlobsMeta(client::GQL.Client, namecontains::String="")
    variables = Dict("name"=>namecontains)
    response = GQL.execute(
        client,
        GQL_LIST_BLOBS_NAME_CONTAINS,
        Vector{NamedTuple{
            (:id,:name,:size,:createdTimestamp), 
            Tuple{UUID,String,String,Union{Nothing,String}}
        }};
        variables,
        throw_on_execution_error = true,
    )
    return response.data["blobs"]
end

## =========================================================================
## Upload
## =========================================================================

"""
$(SIGNATURES)
Request URLs for data blob upload.

Args:
  navAbilityClient (NavAbilityClient): The NavAbility client.
  filename (String): file/blob name.
  filesize (Int): total number of bytes to upload. 
  parts (Int): Split upload into multiple blob parts, FIXME currently only supports parts=1.
"""
function createUpload(
    client::GQL.Client,
    name::AbstractString,
    blobsize::Int,
    parts::Int = 1,
)
    #
    response = GQL.execute(
        client,
        GQL_CREATE_UPLOAD;
        variables = Dict("name" => name, "size" => blobsize, "parts" => parts),
        throw_on_execution_error = true,
    )

    return response.data["createUpload"]
end

## Complete the upload

function completeUploadSingle(
    client::GQL.Client,
    blobId::AbstractString,
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
    blobstore::NavAbilityBlobStore,
    blob::AbstractVector{UInt8},
    filename::AbstractString,
)
    client = blobstore.client

    filesize = length(blob)
    # TODO: Use about a 50M file part here.
    np = 1 # TODO: ceil(filesize / 50e6)
    # create the upload url destination
    d = createUpload(client, filename, filesize, np)

    url = d["parts"][1]["url"]
    uploadId = d["uploadId"]
    blobId = d["blob"]["id"]

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
    res = completeUploadSingle(client, blobId, uploadId, eTag)

    res == "Accepted" ? nothing : @error("Unable to upload blob, $res")

    return UUID(blobId)
end

function addBlob!(
    blobstore::NavAbilityCachedBlobStore,
    blob::AbstractVector{UInt8},
    filename::AbstractString,
)
    safefilename = split(filename,"/")[end]
    blobId = addBlob!(blobstore.remotestore, blob, safefilename)
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