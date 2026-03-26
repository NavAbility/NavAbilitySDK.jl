# Test NavAbilityBlobStore and NavAbilityCachedBlobStore

@testset "NavAbilityBlobStore" begin
    store = NavAbilityBlobStore(client)
    display(store)
    
    blob = rand(UInt8, 8)
    blobId = addBlob!(store, uuid4(), blob)

    @test hasBlob(store, blobId)

    r_blob = getBlob(store, blobId)
    @test blob == r_blob

    #NOTE don't know if this will work if there are too many blobs
    @test blobId in NvaSDK.listBlobs(store)

    @test deleteBlob!(store, blobId) == 1

    @test blobId ∉ NvaSDK.listBlobs(store)
end

@testset "NavAbilityCachedBlobStore" begin
    memstore = DFG.InMemoryBlobstore()
    nvastore = NavAbilityBlobStore(client)
    store = NvaSDK.NavAbilityCachedBlobStore(memstore, nvastore)

    blob = rand(UInt8, 8)
    blobId = addBlob!(store, uuid4(), blob)

    r_blob = getBlob(store, blobId)
    @test blob == r_blob

    # Blob should be cached in the local memory store
    @test haskey(store.localstore.blobs, blobId)

    @test deleteBlob!(store, blobId) == 1
end