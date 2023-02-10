

"""
$(SIGNATURES)
Request URLs for data blob download.

Args:
  navAbilityClient (NavAbilityClient): The NavAbility client.
  userId (String): The userId with access to the data.
  fileId (String): The unique file identifier of the data blob.
"""
function createDownloadEvent(
  navAbilityClient::NavAbilityClient, 
  userId::AbstractString, 
  fileId::UUID
)
  #
  response = navAbilityClient.mutate(MutationOptions(
      "sdk_url_createdownload",
      GQL_CREATEDOWNLOAD,
      Dict(
          "userId" => userId,
          "fileId" => string(fileId)
      )
  )) |> fetch
  rootData = JSON.parse(response.Data)
  if haskey(rootData, "errors")
      throw("Error: $(rootData["errors"])")
  end
  data = get(rootData,"data",nothing)
  if data === nothing return "Error" end
  urlMsg = get(data,"url","Error")
  # TODO: What about marshalling?
  return urlMsg
end

createDownload(w...) = @async createDownloadEvent(w...)

##


function getDataEvent(
  client::NavAbilityClient, 
  userId::AbstractString, 
  fileId::UUID
)
  #
  url = createDownload(client, userId, fileId) |> fetch
  io = PipeBuffer()
  Downloads.download(url, io)
  io
end

getDataEvent(client::NavAbilityClient, context::Client, fileId::UUID) = getDataEvent(client, context.userId, fileId)
getData(client::NavAbilityClient, context::Client, fileId::UUID) = @async getDataEvent(client, context, fileId)
getData(client::NavAbilityClient, userId::AbstractString, fileId::UUID) = @async getDataEvent(client, userId, fileId)


function getDataEntry(
  client::NavAbilityClient,
  context::Client,
  vlbl::AbstractString,
  pattern::Union{Regex, UUID};
  lt=isless, 
  count::Base.RefValue{Int}=Ref(0), # return count of how many matches were found
  skiplist=Symbol[]
)
  ble = listDataEntries(client, context, vlbl) |> fetch
  # filter for the specific blob label
  _matchpatt(regex::Regex, de) = match(regex, de.label) isa Nothing
  _matchpatt(uuid::UUID, de) = uuid != UUID(de.id)
  ble_s = filter(x->!(_matchpatt(pattern, x)), ble) # match(regex,x.label) isa Nothing
  filter!(s-> !(s.label in Symbol.(skiplist)), ble_s)
  count[] = length(ble_s)
  if 0 === count[]
    return nothing
  end
  lbls = (s->s.label).(ble_s)
  idx = sortperm(lbls; lt)
  ble_s[idx]
end
getDataEntry(
  client::NavAbilityClient,
  context::Client,
  vlbl::AbstractString,
  key::AbstractString;
  kw...
) = getDataEntry(client, context, vlbl, Regex(key); kw...)

function getData(
  client::NavAbilityClient, 
  context::Client, 
  vlbl::AbstractString, 
  regex::Regex; 
  verbose::Bool=true,
  datalabel::Base.RefValue{String}=Ref(""),
  kw...
)
  bles = getDataEntry(client, context, vlbl, regex; kw...)
  # skip out if nothing
  bles isa Nothing ? (return nothing) : nothing
  ble_ = bles[end] 
  (verbose && 1 < length(bles)) ? @warn("multiple matches on regex, fetching $(ble_.label), w/ regex: $(regex.pattern), $((s->s.label).(bles))") : nothing
  datalabel[] = ble_.label
  # get blob
  return NVA.getData(client, context, ble_.id)
end
getData(
  client::NavAbilityClient, 
  context::Client, 
  vlbl::AbstractString, 
  key::AbstractString; 
  kw...
) = getData(client, context, vlbl, Regex(key); kw...)



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
function createUploadEvent(
  navAbilityClient::NavAbilityClient, 
  filename::AbstractString, 
  filesize::Int,
  parts::Int=1
)
  #
  response = navAbilityClient.mutate(MutationOptions(
    "sdk_url_createupload",
    GQL_CREATE_UPLOAD,
    Dict(
      "filename" => filename,
      "filesize" => filesize,
      "parts" => parts
    )
  )) |> fetch
  rootData = JSON.parse(response.Data)
  if haskey(rootData, "errors")
    throw("Error: $(rootData["errors"])")
  end
  data = get(rootData,"data",nothing)
  if data === nothing return "Error" end
  uploadResp = get(data,"createUpload","Error")
  # TODO: What about marshalling?
  return uploadResp
end

createUpload(w...) = @async createUploadEvent(w...)


## Complete the upload


function completeUploadSingleEvent(
  navAbilityClient::NavAbilityClient, 
  fileId::AbstractString, 
  uploadId::AbstractString,
  eTag::AbstractString,
)
  response = navAbilityClient.mutate(MutationOptions(
    "completeUpload",
    GQL_COMPLETEUPLOAD_SINGLE,
    Dict(
      "fileId" => fileId,
      "uploadId" => uploadId, 
      "eTag" => eTag
    )
  )) |> fetch
  rootData = JSON.parse(response.Data)
  if haskey(rootData, "errors")
    throw("Error: $(rootData["errors"])")
  end
  data = get(rootData,"data",nothing)
  if data === nothing return "Error" end
  uploadResp = get(data,"completeUpload","Error")
  return uploadResp
end

completeUploadSingle(w...) = @async completeUploadSingleEvent(w...)


##


function addDataEvent(
  client::NavAbilityClient, 
  blobname::AbstractString, 
  blob::AbstractVector{UInt8}
)
  #
  io = IOBuffer(blob)
  
  filesize = length(blob)
  # TODO: Use about a 50M file part here.
  np = 1 # TODO: ceil(filesize / 50e6)
  # create the upload url destination
  d = NVA.createUploadEvent(client, blobname, filesize, np)
  
  url = d["parts"][1]["url"]
  uploadId = d["uploadId"]
  fileId = d["file"]["id"]
  
  # custom header for pushing the file up
  headers = [
    "Content-Length" => filesize,
    "Accept" => "application/json, text/plain, */*",
    "Accept-Encoding" => "gzip, deflate, br",
    "Sec-Fetch-Dest" => "empty",
    "Sec-Fetch-Mode" => "cors",
    "Sec-Fetch-Site" => "cross-site",
    "Sec-GPC" => 1,
    "Connection" => "keep-alive"
  ]
  #

  resp = HTTP.put(url, headers, blob)

  # Extract eTag
  eTag = match(r"[a-zA-Z0-9]+",resp["eTag"]).match

  # close out the upload
  res = NVA.completeUploadSingleEvent(client, fileId, uploadId, eTag)

  res == "Accepted" ? nothing : @error("Unable to upload blob, $res")

  fileId
end


addData(w...) = @async addDataEvent(w...)


##

@deprecate addDataEntryEvent(args...;kwargs...) addBlobEntryEvent(args...;kwargs...)

function addBlobEntryEvent(
  navAbilityClient::NavAbilityClient, 
  userId::AbstractString,
  robotId::AbstractString,
  sessionId::AbstractString,
  variableLabel::AbstractString,
  dataId::AbstractString, # TODO must also support ::UUID
  dataLabel::AbstractString,
  mimeType::AbstractString="",
)
  response = navAbilityClient.mutate(MutationOptions(
    "sdk_addblobentry",
    GQL_ADDBLOBENTRY,
    Dict(
      "userId" => userId,
      "robotId" => robotId,
      "sessionId" => sessionId,
      "variableLabel" => variableLabel,
      "dataId" => dataId,
      "dataLabel" => dataLabel,
      "mimeType" => mimeType,
    )
  )) |> fetch
  rootData = JSON.parse(response.Data)
  if haskey(rootData, "errors")
    throw("Error: $(rootData["errors"])")
  end
  data = get(rootData,"data",nothing)
  if data === nothing return "Error" end
  addentryresp = get(data,"addBlobEntry","Error")
  return addentryresp["context"]["eventId"]
end

addBlobEntryEvent(client::NavAbilityClient, 
                  context::Client, 
                  w...) = addBlobEntryEvent(client, 
                                            context.userId, 
                                            context.robotId, 
                                            context.sessionId, 
                                            w...)
#

addBlobEntry(w...) = @async addBlobEntryEvent(w...)


##


function listDataEntriesEvent(
  navAbilityClient::NavAbilityClient, 
  userId::AbstractString,
  robotId::AbstractString,
  sessionId::AbstractString,
  variableLabel::AbstractString
)
  #
  response = navAbilityClient.mutate(MutationOptions(
    "sdk_listdataentries",
    GQL_LISTDATAENTRIES,
    Dict(
      "userId" => userId,
      "robotId" => robotId,
      "sessionId" => sessionId,
      "variableLabel" => variableLabel
    )
  )) |> fetch
  rootData = JSON.parse(response.Data)
  if haskey(rootData, "errors")
    throw("Error: $(rootData["errors"])")
  end
  data = get(rootData,"data",nothing)
  if data === nothing return "Error" end

  listdata = data["users"][1]["robots"][1]["sessions"][1]["variables"][1]["data"]
  ret = []
  for d in listdata
    tupk = Tuple(Symbol.(keys(d)))
    nt = NamedTuple{tupk}( values(d) )
    push!(ret,
      nt
    )
  end

  return ret
end

listDataEntriesEvent(client::NavAbilityClient, 
                      context::Client, 
                      w...) = listDataEntriesEvent(client, 
                                                    context.userId, 
                                                    context.robotId, 
                                                    context.sessionId, 
                                                    w...)
#

listDataEntries(w...) = @async listDataEntriesEvent(w...)

## 

function listDataBlobsEvent(
  navAbilityClient::NavAbilityClient, 
)
  #
  response = navAbilityClient.query(QueryOptions(
    "sdk_listdatablobs",
    GQL_LISTDATABLOBS,
    Dict()
  )) |> fetch
  rootData = JSON.parse(response.Data)
  if haskey(rootData, "errors")
    throw("Error: $(rootData["errors"])")
  end
  data = get(rootData,"data",nothing)
  if data === nothing return "Error" end

  listdata = data["files"]
  ret = []
  for d in listdata
    tupk = Tuple(Symbol.(keys(d)))
    nt = NamedTuple{tupk}( values(d) )
    push!(ret,
      nt
    )
  end

  return ret
end

#

listDataBlobs(w...) = @async listDataBlobsEvent(w...)



"""
    incrDataLabelSuffix

If the blob label `thisisme` already exists, then this function will return the name `thisisme_1`.
If the blob label `thisisme_1` already exists, then this function will return the name `thisisme_2`.

DO NOT EXPORT, Duplicate functionality from DistributedFactorGraphs.jl.
"""
function incrDataLabelSuffix(
  client::NVA.NavAbilityClient, 
  context::NVA.Client, 
  vla, 
  bllb::AbstractString; 
  datalabel=Ref("")
)
  re_aH = NVA.getData(client, context, string(vla), Regex(bllb); datalabel) |> fetch
  # append latest count
  count, hasund, len = if re_aH isa Nothing
    1, string(bllb)[end] == '_', 0
  else
    datalabel[] = string(bllb)
    @show dlb = match(r"\d*", reverse(datalabel[]))
    # too freakin complicated, but there it is -- add an underscore before the suffix number if not already there
    if occursin(Regex(dlb.match*"_"), reverse(datalabel[]))
      # already suffix e.g. `_1`
      parse(Int, dlb.match |> reverse)+1, true, length(dlb.match)
    else
      # does not yet follow suffix pattern, maybe something like `blobname_x23`
      1, datalabel[][end] == '_', 0
    end
  end
  # the piece from old label without the suffix count number
  bllb = datalabel[][1:(end-len)]
  if !hasund || bllb[end] != '_'
      bllb *= "_"
  end
  bllb *= string(count)
  bllb
end


##
