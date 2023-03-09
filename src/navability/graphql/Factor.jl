GQL_FRAGMENT_FACTORS = """
fragment blobEntry_fields on BlobEntry {
  id
  blobId
  originId
  label
  description
  hash
  mimeType
  blobstore
  origin
  metadata
  timestamp
  _type
  _version
  createdTimestamp
  lastUpdatedTimestamp
}  
fragment factor_skeleton_fields on Factor {
  id
  label
  tags
  _variableOrderSymbols
}
fragment factor_summary_fields on Factor {
  timestamp
  nstime
  _version
  blobEntries {
    ...blobEntry_fields
  }
  createdTimestamp
  lastUpdatedTimestamp
}
fragment factor_full_fields on Factor {
  fnctype
  solvable
  data
}
"""

GQL_GETFACTOR = """
query sdk_get_factor(
    \$userId: ID!, 
    \$robotId: ID!, 
    \$sessionId: ID!,
    \$label: ID!) {
    users(where:{id:\$userId}) {
      robots(where:{id: \$robotId}) {
        sessions(where:{id: \$sessionId}) {
          factors(where:{label: \$label}) {
          ...factor_skeleton_fields
          ...factor_summary_fields
          ...factor_full_fields
        }
      }
    }
  }
}
"""

GQL_GETFACTORS = """
query sdk_get_factors(
    \$userId: ID!, 
    \$robotId: ID!, 
    \$sessionId: ID!,
    \$fields_summary: Boolean! = false, 
    \$fields_full: Boolean! = false){
  users(where:{id:\$userId}) {
    name
    robots(where:{id: \$robotId}) {
      name
      sessions(where:{id: \$sessionId}){
        name
        factors {
          ...factor_skeleton_fields
          ...factor_summary_fields @include(if: \$fields_summary)
          ...factor_full_fields @include(if: \$fields_full)
        }
      }
    }
  }
}
"""

GQL_GETFACTORSFILTERED = """
query sdk_get_factors(
    \$userId: ID!, 
    \$robotIds: [ID!]!, 
    \$sessionIds: [ID!]!, 
    \$factor_label_regexp: String = ".*",
    \$factor_tags: [String] = ["FACTOR"],
    \$solvable: Int! = 0,
    \$fields_summary: Boolean! = false, 
    \$fields_full: Boolean! = false){
  users(where:{id:\$userId}) {
    name
    robots(where:{id_IN: \$robotIds}) {
      name
      sessions(where:{id_IN: \$sessionIds}){
        name
        factors(where:{
          label_MATCHES: \$factor_label_regexp, 
          tags: \$factor_tags, 
          solvable_GTE: \$solvable}) {
          ...factor_skeleton_fields
          ...factor_summary_fields @include(if: \$fields_summary)
          ...factor_full_fields @include(if: \$fields_full)
        }
      }
    }
  }
}
"""

GQL_ADD_FACTOR_PACKED = """
  mutation sdk_add_factor_packed(
      \$factorPackedInput: AddFactorPackedInput!, 
      \$options: AddFactorPackedOptionsInput
    ) {
    addFactorPacked(factor: \$factorPackedInput, options:\$options) {
      context {
        eventId
      }  
      status {
        state
        progress
      }
    }
  }"""

GQL_DELETEFACTOR = """
  mutation sdk_delete_factor(
    \$factor: DeleteFactorInput!, 
    \$options: DeleteFactorOptionsInput
  ) {
  deleteFactor(factor: \$factor, options: \$options) {
    context {
      eventId
    }
    status {
      state
      progress
    }
  }
}
"""
