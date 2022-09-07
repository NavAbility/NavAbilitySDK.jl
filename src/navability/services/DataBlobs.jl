

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
    fileId::AbstractString
  )
  #
  response = navAbilityClient.mutate(MutationOptions(
      "sdk_url_createdownload",
      GQL_CREATEDOWNLOAD,
      Dict(
          "userId" => userId,
          "fileId" => fileId
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
    fileId::AbstractString
  )
  #
  url = createDownload(client, userId, fileId) |> fetch
  io = PipeBuffer()
  Downloads.download(url, io)
  io
end

getDataEvent(client::NavAbilityClient, context::Client, w...) = getDataEvent(client, context.userId, w...)
getData(w...) = @async getDataEvent(w...)

function getDataEntry(
  client::NavAbilityClient,
  context::Client,
  vlbl::AbstractString,
  regex::Regex;
  lt=isless, 
  count::Base.RefValue{Int}=Ref(0), # return count of how many matches were found
)
  ble = listDataEntries(client, context, vlbl) |> fetch
  # filter for the specific blob label
  ble_s = filter(x->!(match(regex,x.label) isa Nothing) , ble)
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
    GQL_CREATEUPLOAD,
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
  
  filesize = io.size
  np = 1
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

  # fid = open(filepath,"r")
  resp = HTTP.put(url, headers, io)
  # close(fid)

  # Extract eTag
  eTag = match(r"[a-zA-Z0-9]+",resp["eTag"]).match

  # close out the upload
  res = NVA.completeUploadSingleEvent(client, fileId, uploadId, eTag)

  res == "Accepted" ? nothing : @error("Unable to upload blob, $res")

  fileId
end


addData(w...) = @async addDataEvent(w...)


##


function addDataEntryEvent(
    navAbilityClient::NavAbilityClient, 
    userId::AbstractString,
    robotId::AbstractString,
    sessionId::AbstractString,
    variableLabel::AbstractString,
    dataId::AbstractString,
    dataLabel::AbstractString,
    mimeType::AbstractString="",
  )
  response = navAbilityClient.mutate(MutationOptions(
    "sdk_adddataentry",
    GQL_ADDDATAENTRY,
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
  addentryresp = get(data,"addDataEntry","Error")
  return addentryresp
end

addDataEntryEvent(client::NavAbilityClient, 
                  context::Client, 
                  w...) = addDataEntryEvent(client, 
                                            context.userId, 
                                            context.robotId, 
                                            context.sessionId, 
                                            w...)
#

addDataEntry(w...) = @async addDataEntryEvent(w...)


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