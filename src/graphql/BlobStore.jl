
GQL_CREATE_UPLOAD = """
mutation sdk_url_createupload(\$filename: String!, \$filesize: BigInt!, \$parts: Int!) {
  createUpload(
    file: {
      filename: \$filename,
      filesize: \$filesize
    },
    parts: \$parts
  ) {
    uploadId
    parts {
      partNumber
      url
    }
    file {
      id
    }
  }
}
"""

GQL_COMPLETEUPLOAD_SINGLE = """
mutation completeUpload(\$fileId: ID!, \$uploadId: ID!, \$eTag: String) {
  completeUpload (
    fileId: \$fileId,
    completedUpload: {
      uploadId: \$uploadId,
      parts: [
        {
          partNumber: 1,
          eTag: \$eTag
        }
      ]
    }
  )
}
"""

GQL_LISTBLOBS = """
query listBlobs {
  files {
    id
    filename
    filesize
  }
}
"""