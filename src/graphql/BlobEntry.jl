GQL_FRAGMENT_BLOBENTRY = """
fragment blobEntry_fields on BlobEntry {
  id
  blobId
  originId
  label
  blobstore
  hash
  origin
  description
  mimeType
  metadata
  timestamp
  _type
  _version
}
"""

GQL_GET_BLOBENTRY = """
$(GQL_FRAGMENT_BLOBENTRY)
query get_blob_entry(
  \$userId: String!
  \$robotId: String!
  \$sessionId: String!
  \$variableId: String!
  \$blobLabel: String!
) {
  users(where: { id_MATCHES: \$userId }) {
    robots(where: { id_MATCHES: \$robotId }) {
      sessions(where: { id_MATCHES: \$sessionId }) {
        variables(where: { id_MATCHES: \$variableId }) {
          blobEntries(where: { label_MATCHES: \$blobLabel }) {
            ...blobEntry_fields
          }
        }
      }
    }
  }
}
"""

GQL_ADD_BLOBENTRIES = """
$(GQL_FRAGMENT_BLOBENTRY)
mutation addBlobEntries(\$blobEntries: [BlobEntryCreateInput!]!) {
  # Create the new ones
  addBlobEntries(
    input: \$blobEntries
  ) {
    blobEntries {
      ...blobEntry_fields
    }
  }
}
"""

GQL_LIST_BLOBENTRIES = """
query listBlobEntries(\$userId: ID!, \$robotId: ID!, \$sessionId: ID!, \$variableId: ID!) {
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
          where: {id: \$variableId}
        ) {
          blobEntries {
            label
          }
        }
      }
    }
  }
}
"""

# GQL_UPDATE_BLOBENTRY = """
# $(GQL_FRAGMENT_BLOBENTRY)
# mutation updateBlobEntry(\$blobEntry: BlobEntryUpdateInput!, \$uniqueKey: String!) {
#   updateDataEntries(
#     update: \$blobEntry
#     where: {uniqueKey: \$uniqueKey}
#   ) {
#     blobEntries {
#       ...blobEntry_fields
#     }
#   }
# }
# """

# GQL_DELETE_BLOBENTRY = """
# mutation deleteBlobEntry(\$uniqueKey: String!) {
#   deleteDataEntries(
#     where: {uniqueKey: \$uniqueKey}
#   ) {
#     nodesDeleted
#   }
# }
# """
