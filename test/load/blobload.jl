## 
## On-demand load testing script for range of blob upload/download scenarios 
##
using Test
using Random
using NavAbilitySDK
using Base64
using JSON3

using TimerOutputs

apiUrl = get(ENV,"API_URL","https://api.navability.io")
userId = get(ENV,"USER_ID","guest@navability.io")
robotId = get(ENV,"ROBOT_ID","IntegrationRobot")
sessionId = get(ENV,"SESSION_ID","TestSession"*randstring(7))

include("../integration/fixtures.jl")
# @testset "Blob load test" begin
client = NavAbilityHttpsClient(apiUrl)
context = Client(userId,robotId,sessionId)
  # client, context = createClients(apiUrl, userId, robotId, sessionId)

to = TimerOutput()

## 
data1M = JSON3.write(rand(Float64, 512*1024))[1:1024*1024];
@info "1Mb files"
for i in 1:20
  @info "Iteration $(i)"
  fileId = @timeit to "[Serial] Add 1Mb Data" NVA.addData(client, "LoadTest", codeunits(data1M)) |> fetch
  data1MRet = @timeit to "[Serial] Get 1Mb Data" NVA.getData(client, context, fileId) |> fetch |> take! 
  # @timeit to "List files" NVA.li
  @test codeunits(data1M) == data1MRet
  @info "Validated data, file ID $(fileId)"
end

data10M = JSON3.write(rand(Float64, 512*1024*10))[1:10*1024*1024];
@info "10Mb files"
for i in 1:20
  @info "Iteration $(i)"
  fileId = @timeit to "[Serial] Add 10Mb Data" NVA.addData(client, "LoadTest", codeunits(data10M)) |> fetch
  data10MRet = @timeit to "[Serial] Get 10Mb Data" NVA.getData(client, context, fileId) |> fetch |> take! 
  # @timeit to "List files" NVA.li
  @test codeunits(data10M) == data10MRet
  @info "Validated data, file ID $(fileId)"
end

data100M = JSON3.write(rand(Float64, 512*1024*100))[1:1024*1024*100];
@info "100Mb files"
for i in 1:10
  @info "Iteration $(i)"
  fileId = @timeit to "[Serial] Add 100Mb Data" NVA.addData(client, "LoadTest", codeunits(data100M)) |> fetch
  data100MRet = @timeit to "[Serial] Get 100Mb Data" NVA.getData(client, context, fileId) |> fetch |> take! 
  # @timeit to "List files" NVA.li
  @test codeunits(data100M) == data100MRet
  @info "Validated data, file ID $(fileId)"
end

for i in 1:20
  @timeit to "List Blobs" NVA.listDataBlobs(client) |> fetch
end

## Parallel file uploads
parallelSet = 1:20
fileIds = @timeit to "[Parallel] Add 1Mb Data [20 files total]" (
    map(r -> (NVA.addData(client, "LoadTest", codeunits(data1M))), parallelSet) .|> fetch)
data1MRets = @timeit to "[Parallel] Get 1Mb Data [20 files total]" (
    map(fileId -> NVA.getData(client, context, fileId), fileIds) .|> fetch .|> take!);
@test all(map(dRet -> codeunits(data1M) == dRet, data1MRets))

to

# end