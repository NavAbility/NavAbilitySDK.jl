using ..NavAbilitySDK
using JSON

function getFiles(navAbilityClient: NavAbilityClient)
  response = navAbilityClient.query(QueryOptions(
    "sdk_get_files",
    GQL_GETFILES
  ))
  rootData = JSON.parse(response.Data)
  if haskey(rootData, "errors")
    throw("Error: $(rootData["errors"])")
  end
  data = get(rootData,"data",nothing)
  if data === nothing return Dict() end
  files = get(data,"files",[])
  return files
end

function addFile(navAbilityClient::NavAbilityClient, file)
  # TODO: Create Upload
  # TODO: Upload via url
  # TODO: Complete Upload
end

function addDataEntry(navAbilityClient::NavAbilityClient, client::Client, file::File, label::String)
  response = navAbilityClient.mutate(MutationOptions(
    "sdk_add_dataentry",
    GQL_ADDDATAENTRY,
    Dict(
        "client" => client,
        "blobStoreEntry" => file,
        "nodeLabel" => label
    )
  ))
  rootData = JSON.parse(response.Data)
  if haskey(rootData, "errors")
    throw("Error: $(rootData["errors"])")
  end
  data = get(rootData,"data",nothing)
  if data === nothing return Dict() end
  dataEntry = get(data,"addDataEntry","")
  return dataEntry
end

function addData(navAbilityClient::NavAbilityClient, client::Client, file::File, label::String)
  savedFile = addFile(navAbilityClient,file)
  addDataEntry(navAbilityClient,client,savedFile,label)
end
