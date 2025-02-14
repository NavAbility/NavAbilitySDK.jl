using NavAbilitySDK
using Test

auth_token = ENV["AUTH_TOKEN"]
apiUrl = get(ENV, "API_URL", "https://api.navability.io/graphql")
agentLabel = :TestRobot
fgLabel = Symbol("TestSession_", randstring(7))

@testset "Test NavAbilityBlobStore" begin

    client = NavAbilityClient(auth_token, apiUrl)
    store = NavAbilityBlobStore(client)
    display(store)
    
    blob = rand(UInt8, 8)
    
    blobId = addBlob!(store, uuid4(), blob)

    @test hasBlob(store, blobId)
    @test blobId in listBlobs(store)

    r_blob = getBlob(store, blobId)

    @test blob == r_blob

    #NOTE don't know if this will work if there are too many blobs
    @test blobId in NvaSDK.listBlobs(store)

    # FIXME it looks like this always retruns "Success"
    @test deleteBlob!(store, blobId) == "Success"

end

@testset "Test NavAbilityCachedBlobStore" begin

    client = NavAbilityClient(auth_token, apiUrl)
    memstore = NvaSDK.DFG.InMemoryBlobStore()
    nvastore = NavAbilityBlobStore(client)

    store = NvaSDK.NavAbilityCachedBlobStore(memstore, nvastore)
    
    blob = rand(UInt8, 8)
    
    blobId = addBlob!(store, blob)

    r_blob = getBlob(store, blobId)

    @test blob == r_blob

    #blob should be cached in memory blobstore
    @test haskey(store.localstore.blobs, blobId)

end
