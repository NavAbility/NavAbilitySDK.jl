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
  \$userId: ID!
  \$robotId: ID!
  \$sessionId: ID!
  \$variableLabel: String!
  \$blobLabel: String!
) {
  users(where: { id: \$userId }) {
    robots(where: { id: \$robotId }) {
      sessions(where: { id: \$sessionId }) {
        variables(where: { label: \$variableLabel }) {
          blobEntries(where: { label: \$blobLabel }) {
            ...blobEntry_fields
          }
        }
      }
    }
  }
}
"""

GQL_GET_BLOBENTRIES = """
$(GQL_FRAGMENT_BLOBENTRY)
query get_blob_entries(
  \$userId: ID!
  \$robotId: ID!
  \$sessionId: ID!
  \$variableLabel: String!
) {
  users(where: { id: \$userId }) {
    robots(where: { id: \$robotId }) {
      sessions(where: { id: \$sessionId }) {
        variables(where: { label: \$variableLabel }) {
          blobEntries {
            ...blobEntry_fields
          }
        }
      }
    }
  }
}
"""

# label_IN
# label_MATCHES
# label_CONTAINS
# label_STARTS_WITH
# label_ENDS_WITH

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
query listBlobEntries(\$userId: ID!, \$robotId: ID!, \$sessionId: ID!, \$variableLabel: String!) {
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
          blobEntries {
            label
          }
        }
      }
    }
  }
}
"""

GQL_LIST_SESSION_BLOBENTRIES = GQL.gql"""
query listSessionBlobEntries($userId: ID!, $robotId: ID!, $sessionId: ID!) {
  users(where: { id: $userId }) {
    robots(where: { id: $robotId }) {
      sessions(where: { id: $sessionId }) {
        blobEntries {
          label
        }
      }
    }
  }
}
"""

GQL_GET_USER_BLOBENTRY = """
$(GQL_FRAGMENT_BLOBENTRY)
query getUserBlobEntry(
  \$userId: ID!
  \$blobLabel: String!
) {
  users(where: { id: \$userId }) {
    blobEntries(where: { label: \$blobLabel }) {
      ...blobEntry_fields
    }
  }
}
"""

GQL_GET_ROBOT_BLOBENTRY = """
$(GQL_FRAGMENT_BLOBENTRY)
query getRobotBlobEntry(
  \$userId: ID!
  \$robotId: ID!
  \$blobLabel: String!
) {
  users(where: { id: \$userId }) {
    robots(where: { id: \$robotId }) {
      blobEntries(where: { label: \$blobLabel }) {
        ...blobEntry_fields
      }
    }
  }
}
"""

GQL_GET_SESSION_BLOBENTRY = """
$(GQL_FRAGMENT_BLOBENTRY)
query getSessionBlobEntry(
  \$userId: ID!
  \$robotId: ID!
  \$sessionId: ID!
  \$blobLabel: String!
) {
  users(where: { id: \$userId }) {
    robots(where: { id: \$robotId }) {
      sessions(where: { id: \$sessionId }) {
        blobEntries(where: { label: \$blobLabel }) {
          ...blobEntry_fields
        }
      }
    }
  }
}
"""

GQL_GET_SESSION_BLOBENTRIES = """
$(GQL_FRAGMENT_BLOBENTRY)
query getSessionBlobEntries(
  \$userLabel: EmailAddress!
  \$robotLabel: String!
  \$sessionLabel: String!
  \$startwith: String
) {
  users(where: { label: \$userLabel }) {
    robots(where: { label: \$robotLabel }) {
      sessions(where: { label: \$sessionLabel }) {
        blobEntries(where: { label_STARTS_WITH: \$startwith }) {
          ...blobEntry_fields
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
