GQL_GETFILES = """
  query sdk_get_files {
    files {
      id
      filename
    }
  }"""

GQL_ADDDATAENTRY = """
  mutations sdk_add_dataentry (\$dataEntry: DataEntryInput) {
    addDataEntry (dataEntry: \$dataEntry)
  }"""

GQL_CREATEUPLOAD = """
  mutation sdk_create_upload (\$file: FileInput!, \$parts: Int) {
    createUpload(file: \$file, parts: \$parts) {
      uploadId
      file {
        id
        filename
        filesize
      }
      parts {
        partNumber
        url
      }
    }
  }"""

GQL_ABORTUPLOAD = """
  mutation sdk_abort_upload (\$fileId: ID!, \$uploadId: ID!) {
    abortUpload(fileId: \$fileId, uploadId: \$uploadId)
  }"""

GQL_COMPLETEUPLOAD = """
  mutation sdk_complete_upload (\$fileId: ID!, \$completedUpload: CompletedUploadInput!) {
    completeUpload(fileId: \$fileId, completedUpload: \$completedUpload)
  }"""