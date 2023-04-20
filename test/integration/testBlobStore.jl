using NavAbilitySDK

apiUrl = get(ENV, "API_URL", "https://api.navability.io")
userLabel = get(ENV, "USER_ID", "guest@navability.io")


@testset "Test NavAbilityBlobStore" begin

    client = NavAbilityClient(apiUrl)
    store = NavAbilityBlobStore(client, userLabel)
    display(store)
    
    blob = rand(UInt8, 8)
    
    blobId = addBlob!(store, blob, "TestBlobStore_Blob.dat")

    r_blob = getBlob(store, blobId)

    @test blob == r_blob

    #NOTE don't know if this will work if there are too many blobs
    @test blobId in NvaSDK.listBlobsId(client)

    blobsmeta = NvaSDK.listBlobsMeta(client, "TestBlobStore_Blob")

    @test blobId in getproperty.(blobsmeta, :id)

    # FIXME it looks like this always retruns "Success"
    @test deleteBlob!(store, blobId) == "Success"

    blobsmeta = NvaSDK.listBlobsMeta(client, "TestBlobStore_Blob")

    @test !in(blobId, getproperty.(blobsmeta, :id))

end



@testset "Test NavAbilityCachedBlobStore" begin

    client = NavAbilityClient(apiUrl)
    memstore = NvaSDK.DFG.InMemoryBlobStore()
    nvastore = NavAbilityBlobStore(client, userLabel)

    store = NvaSDK.NavAbilityCachedBlobStore(memstore, nvastore)
    
    blob = rand(UInt8, 8)
    
    blobId = addBlob!(store, blob, "TestCachedBlobStore_Blob.dat")

    r_blob = getBlob(store, blobId)

    @test blob == r_blob

    #blob should be cached in memory blobstore
    @test haskey(store.localstore.blobs, blobId)

end
