#TODO we can also extend the blobstore
# struct NavAbilityBlobStore <: AbstractBlobStore{Vector{UInt8}}
#   client::GQL.Client
#   userLabel::String
# end


"""
$(SIGNATURES)
Request URLs for data blob download.

Args:
  navAbilityClient (NavAbilityClient): The NavAbility client.
  userLabel (String): The userLabel with access to the data.
  fileId (String): The unique file identifier of the data blob.
"""
function createDownload(client::GQL.Client, userLabel::AbstractString, blobId::UUID)
    response = GQL.mutate(
        client,
        "createDownload",
        Dict("userId" => userLabel, "fileId" => string(blobId));
        throw_on_execution_error = true,
    )
    #TODO API is a bit confusing as it is the user label that works here, ie. guest@navability.io
    return response.data["createDownload"]
    # data = get(response,"data",nothing)
    # if data === nothing || !haskey(data, "url") throw(KeyError("Cannot create download for $userLabel, requesting $blobId.\n$rootData")) end
    # urlMsg = get(data,"url","Error")
    # # TODO: What about marshalling?
    # return urlMsg
end

##
function getBlob(client::GQL.Client, userLabel::AbstractString, blobId::UUID)
    #
    url = createDownload(client, userLabel, blobId)
    io = PipeBuffer()
    Downloads.download(url, io)
    return io |> take!
end

function listBlobsId(client::GQL.Client)
    response = GQL.query(
        client,
        "files",
        Vector{NamedTuple{(:id,), Tuple{UUID}}};
        output_fields = ["id"],
        throw_on_execution_error = true,
    )
    return last.(response.data["files"])
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
    filename::AbstractString,
    filesize::Int,
    parts::Int = 1,
)
    #
    response = GQL.execute(
        client,
        GQL_CREATE_UPLOAD;
        variables = Dict("filename" => filename, "filesize" => filesize, "parts" => parts),
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
        variables = Dict("fileId" => blobId, "uploadId" => uploadId, "eTag" => eTag),
        throw_on_execution_error = true,
    )

    return response.data["completeUpload"]
end

##

function addBlob(
    client::GQL.Client,
    filename::AbstractString,
    blob::AbstractVector{UInt8},
)
    #
    # io = IOBuffer(blob)

    filesize = length(blob)
    # TODO: Use about a 50M file part here.
    np = 1 # TODO: ceil(filesize / 50e6)
    # create the upload url destination
    d = createUpload(client, filename, filesize, np)

    url = d["parts"][1]["url"]
    uploadId = d["uploadId"]
    blobId = d["file"]["id"]

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

    return blobId
end
#TODO
#= 
"""
    $SIGNATURES
Get the data blob as defined by a unique `blobId::UUID` identifier.

DevNotes
- TODO standardize return type as `::Vector{UInt8}` (not an IOBuffer/PipeBuffer)

See also: [`listBlobEntries`](@ref)
"""

function getBlobAsync(
    client::GQL.Client,
    context::Client,
    vlbl::AbstractString,
    regex::Regex;
    verbose::Bool = true,
    datalabel::Base.RefValue{String} = Ref(""),
    kw...,
)
    bles = getBlobEntry(client, context, vlbl, regex; kw...)
    # skip out if nothing
    bles isa Nothing ? (return nothing) : nothing
    ble_ = bles[end]
    if (verbose && 1 < length(bles))
        @warn(
            "multiple matches on regex, fetching $(ble_.label), w/ regex: $(regex.pattern), $((s->s.label).(bles))"
        )
    else
        nothing
    end
    datalabel[] = ble_.label
    # get blob
    return NvaSDK.getBlobAsync(client, context, ble_.id)
end

=#