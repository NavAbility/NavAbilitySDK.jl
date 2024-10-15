
GQL_CREATE_UPLOAD = GQL.gql"""
mutation createUpload($blobId: ID!, $store: BlobStoreInput = {label: "default", type: NVA_CLOUD}, $parts: Int = 1) {
  createUpload(store: $store, blobId: $blobId, parts: $parts) {
    blobId
    uploadId
    parts {
      partNumber
      url
    }
  }
}
"""

GQL_COMPLETEUPLOAD_SINGLE = GQL.gql"""
mutation completeUpload($blobId: ID!, $uploadId: ID!, $eTag: String, $store: BlobStoreInput = {label: "default", type: NVA_CLOUD}) {
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

GQL_LIST_BLOBS_NAME_CONTAINS = GQL.gql"""
query($name: String!) {
  blobs(where: { name_CONTAINS: $name }) {
    id
    name
    size
    createdTimestamp
  }
}
"""
