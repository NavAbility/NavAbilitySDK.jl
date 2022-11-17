

GQL_CREATEDOWNLOAD = """
mutation sdk_url_createdownload (\$userId: String!, \$fileId: ID!) {
  url: createDownload(
    userId: \$userId
    fileId: \$fileId
  )
}
"""


GQL_CREATE_UPLOAD = """
mutation sdk_url_createupload(\$filename: String!, \$filesize: Int!, \$parts: Int!) {
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


GQL_ADDDATAENTRY = """
mutation sdk_adddataentry(\$userId: ResourceId!, \$robotId: ResourceId!, \$sessionId: ResourceId!, \$variableLabel: String!, \$dataId: UUID!, \$dataLabel: String!, \$mimeType: String) {
  addDataEntry (
    dataEntry: {
      client: {
        userId: \$userId,
        robotId: \$robotId,
        sessionId: \$sessionId
      },
      blobStoreEntry: {
        id: \$dataId,
        label: \$dataLabel
        mimetype: \$mimeType
      },
      nodeLabel: \$variableLabel
    }
  )
}
"""


GQL_LISTDATAENTRIES = """
query sdk_listdataentries(\$userId: ID!, \$robotId: ID!, \$sessionId: ID!, \$variableLabel: ID!) {
  users (
    where: {id: \$userId}
  ) {
    robots (
      where: {id: \$robotId}
    ) {
      sessions (
        where: {id: \$sessionId}
      ) {
        variables (
          where: {label: \$variableLabel}
        ) {
          data {
            id
            label
            mimeType
          }
        }
      }
    }
  }
}
"""