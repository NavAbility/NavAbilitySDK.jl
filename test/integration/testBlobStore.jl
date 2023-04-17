using NavAbilitySDK

apiUrl = get(ENV, "API_URL", "https://api.d1.navability.io")
userLabel = get(ENV, "USER_ID", "guest@navability.io")


@testset "Test NavAbilityBlobStore" begin

    client = NvaSDK.NavAbilityClient(apiUrl)
    store = NavAbilityBlobStore(client, userLabel)
    display(store)
    
    blob = rand(UInt8, 8)
    
    blobId = addBlob!(store, blob, "TestBlobStore_Blob.dat")

    r_blob = getBlob(store, blobId)

    @test blob == r_blob


end
