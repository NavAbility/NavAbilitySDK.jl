
GQL_CREATE_UPLOAD = GQL.gql"""
mutation sdk_url_createupload($name: String!, $size: BigInt!, $parts: Int!) {
  createUpload(
    blob: {
      name: $name,
      size: $size
    },
    parts: $parts
  ) {
    uploadId
    parts {
      partNumber
      url
    }
    blob {
      id
    }
  }
}
"""

GQL_COMPLETEUPLOAD_SINGLE = GQL.gql"""
mutation completeUpload($blobId: ID!, $uploadId: ID!, $eTag: String) {
  completeUpload (
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
