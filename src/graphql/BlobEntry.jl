GQL_FRAGMENT_BLOBENTRY = """
fragment blobEntry_fields on Blobentry {
  id
  blobid
  label
  blobstore
  crchash
  shahash
  origin
  size
  description
  mimetype
  metadata
  timestamp
  createdtime
  modifiedtime
  version
}
"""

GQL_GET_BLOBENTRY = """
$(GQL_FRAGMENT_BLOBENTRY)
query get_blob_entry(
  \$id: UUID!
) {
  blobentries(where: { id: {eq: \$id} }) {
    ...blobEntry_fields
  }
}
"""

GQL_GET_BLOBENTRIES = """
$(GQL_FRAGMENT_BLOBENTRY)
query get_blob_entries(
  \$id: UUID!
) {
  variables(where: { id: {eq: \$id} }) {
    blobentries {
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
mutation addBlobentries(\$blobentries: [BlobentryCreateInput!]!) {
  # Create the new ones
  addBlobentries(
    input: \$blobentries
  ) {
    blobentries {
      ...blobEntry_fields
    }
  }
}
"""

GQL_LIST_BLOBENTRIES = """
query listBlobEntries(\$id: UUID!) {
  variables (
    where: {id: {eq: \$id}}
  ) {
    blobentries {
      label
    }
  }
}
"""

GQL_LIST_FACTORGRAPH_BLOBENTRIES = GQL.gql"""
query listGraphBlobEntries($id: UUID!) {
  graphs(where: { id: {eq: $id} }) {
    blobentries {
      label
    }
  }
}
"""

GQL_LIST_AGENT_BLOBENTRIES = GQL.gql"""
query listAgentBlobEntries($id: UUID!) {
  agents(where: { id: {eq: $id} }) { 
    blobentries {
      label
    } 
  }
}
"""

GQL_LIST_MODEL_BLOBENTRIES = GQL.gql"""
query listModelBlobEntries($id: UUID!) {
  models(where: { id: {eq: $id} }) { 
    blobentries {
      label
    } 
  }
}
"""

GQL_GET_FG_BLOBENTRIES = """
$(GQL_FRAGMENT_BLOBENTRY)
query getGraphBlobEntries(\$id: UUID!, \$entrywhere: BlobentryWhere = {}) {
  graphs(where: { id: {eq: \$id} }) {
    blobentries (where: \$entrywhere) {
      ...blobEntry_fields
    }
  }
}
"""

GQL_GET_AGENT_BLOBENTRIES = """
$(GQL_FRAGMENT_BLOBENTRY)
query getAgentBlobEntries(\$id: UUID!, \$entrywhere: BlobentryWhere = {}) {
  agents(where: { id: {eq: \$id} }) { 
    blobentries (where: \$entrywhere) {
      ...blobEntry_fields
    } 
  }
}
"""

GQL_GET_MODEL_BLOBENTRIES = """
$(GQL_FRAGMENT_BLOBENTRY)
query getModelBlobEntries(\$id: UUID!, \$entrywhere: BlobentryWhere = {}) {
  models(where: { id: {eq: \$id} }) { 
    blobentries (where: \$entrywhere) {
      ...blobEntry_fields
    } 
  }
}
"""

GQL_DELETE_BLOBENTRY = GQL.gql"""
mutation deleteBlobentry($id: UUID!) {
  deleteBlobentries(where: { id: {eq: $id} }) {
    nodesDeleted
  }
}
"""

# GQL_UPDATE_BLOBENTRY = """
# $(GQL_FRAGMENT_BLOBENTRY)
# mutation updateBlobentry(\$blobEntry: BlobentryUpdateInput!, \$uniqueKey: String!) {
#   updateDataEntries(
#     update: \$blobEntry
#     where: {uniqueKey: \$uniqueKey}
#   ) {
#     blobentries {
#       ...blobEntry_fields
#     }
#   }
# }
# """

# GQL_DELETE_BLOBENTRY = """
# mutation deleteBlobentry(\$uniqueKey: String!) {
#   deleteDataEntries(
#     where: {uniqueKey: \$uniqueKey}
#   ) {
#     nodesDeleted
#   }
# }
# """
