GQL_FRAGMENT_BLOBENTRY = """
fragment blobEntry_fields on BlobEntry {
  id
  blobId
  originId
  label
  blobstore
  hash
  origin
  size
  description
  mimeType
  metadata
  timestamp
  createdTimestamp
  lastUpdatedTimestamp
  _version
  _type
}
"""

GQL_GET_BLOBENTRY = """
$(GQL_FRAGMENT_BLOBENTRY)
query get_blob_entry(
  \$id: ID!
) {
  blobEntries(where: { id: \$id }) {
    ...blobEntry_fields
  }
}
"""

GQL_GET_BLOBENTRIES = """
$(GQL_FRAGMENT_BLOBENTRY)
query get_blob_entries(
  \$id: ID!
) {
  variables(where: { id: \$id }) {
    blobEntries {
      ...blobEntry_fields
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
query listBlobEntries(\$id: ID!) {
  variables (
    where: {id: \$id}
  ) {
    blobEntries {
      label
    }
  }
}
"""

GQL_LIST_FACTORGRAPH_BLOBENTRIES = GQL.gql"""
query listFgBlobEntries($id: ID!) {
  factorgraphs(where: { id: $id }) {
    blobEntries {
      label
    }
  }
}
"""

GQL_LIST_AGENT_BLOBENTRIES = GQL.gql"""
query listAgentBlobEntries($id: ID!) {
  agents(where: { id: $id }) { 
    blobEntries {
      label
    } 
  }
}
"""

GQL_LIST_MODEL_BLOBENTRIES = GQL.gql"""
query listModelBlobEntries($id: ID!) {
  models(where: { id: $id }) { 
    blobEntries {
      label
    } 
  }
}
"""

GQL_GET_FG_BLOBENTRIES = """
$(GQL_FRAGMENT_BLOBENTRY)
query getFgBlobEntries(\$id: ID!) {
  factorgraphs(where: { id: \$id }) {
    blobEntries {
      ...blobEntry_fields
    }
  }
}
"""

GQL_GET_AGENT_BLOBENTRIES = """
$(GQL_FRAGMENT_BLOBENTRY)
query getAgentBlobEntries(\$id: ID!) {
  agents(where: { id: \$id }) { 
    blobEntries {
      ...blobEntry_fields
    } 
  }
}
"""

GQL_GET_MODEL_BLOBENTRIES = """
$(GQL_FRAGMENT_BLOBENTRY)
query getModelBlobEntries(\$id: ID!) {
  models(where: { id: \$id }) { 
    blobEntries {
      ...blobEntry_fields
    } 
  }
}
"""

GQL_DELETE_BLOBENTRY = GQL.gql"""
mutation deleteBlobEntry($id: ID!) {
  deleteBlobEntries(where: { id: $id }) {
    nodesDeleted
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
