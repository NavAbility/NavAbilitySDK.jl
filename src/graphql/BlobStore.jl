MUTATION_CREATE_DOWNLOAD = GQL.gql"""
mutation createDownload($blobId: ID!, $label: String = "default", $type: BlobStoreType = NVA_CLOUD) {
  createDownload(blobId: $blobId, store: {label: $label, type: $type})
}
"""

GQL_CREATE_UPLOAD = GQL.gql"""
mutation createUpload(
  $blobId: ID!, 
  $store: BlobStoreInput = {
    label: "default", 
    type: NVA_CLOUD
  }, 
  $parts: Int = 1
) {
  createUpload(
    store: $store, 
    blobId: $blobId, 
    parts: $parts
  ) {
    blobId
    uploadId
    parts {
      partNumber
      url
    }
  }
}
"""

GQL_COMPLETEUPLOAD = GQL.gql"""
mutation CompleteUpload (
  $blobId: ID!, 
  $completedUpload: CompletedUploadInput!,
) {
  completeUpload(
    store: {
      label: "default", 
      type: NVA_CLOUD
    },
    blobId: $blobId
    completedUpload: $completedUpload
  )
}
"""

GQL_COMPLETEUPLOAD_SINGLE = GQL.gql"""
mutation completeUpload(
  $blobId: ID!, $uploadId: ID!, 
  $eTag: String, 
  $store: BlobStoreInput = {
    label: "default", 
    type: NVA_CLOUD
  }
) {
  completeUpload (
    store: $store,
    blobId: $blobId,
    completedUpload: {
      uploadId: $uploadId,
      parts: [
        {
          partNumber: 1,
          eTag: $eTag
        }
      ]
    }
  )
}
"""

MUTATION_DELETE_BLOB = GQL.gql"""
mutation deleteBlob($blobId: ID!, $label: String = "default", $type: BlobStoreType = NVA_CLOUD) {
    deleteBlob(blobId: $blobId, store: {label: $label, type: $type})
}
"""

QUERY_LIST_BLOBS = GQL.gql"""
query listBlobs($label: String = "default", $type: BlobStoreType = NVA_CLOUD) {
  listBlobs(store: {label: $label, type: $type})
}
"""

QUERY_HAS_BLOB = GQL.gql"""
query hasBlob($blobId: ID!, $label: String = "default", $type: BlobStoreType = NVA_CLOUD) {
  hasBlob(blobId: $blobId, store: {label: $label, type: $type})
}
"""

# Only for NavAbilityOnPremBlobStore - may be removed in the future
QUERY_GET_BLOB = GQL.gql"""
query getBlob($id: String!, $storeLabel: String = "default") {
    getBlob(blobId: $id, storeLabel: $storeLabel)
}
"""

GQL_ADD_BLOB_FS = GQL.gql"""
mutation addBlobFS($blobId: String, $input: String, $storeLabel: String) {
  addBlobFS(blobId: $blobId, input: $input, storeLabel: $storeLabel)
}
"""
