GQL_FRAGMENT_FACTORS = """
fragment factor_skeleton_fields on Factor {
  label
  tags
  _variableOrderSymbols
}
fragment factor_summary_fields on Factor {
  timestamp
  _version
}
fragment factor_full_fields on Factor {
  fnctype
  solvable
  data
}
"""

GQL_LISTFACTORS = """
query sdk_list_factors (
    \$userId: ID!, 
    \$robotId: ID!, 
    \$sessionId: ID!) {
  users(where:{id: \$userId}) {
    robots(where:{id: \$robotId}) {
      sessions(where:{id: \$sessionId}) {
        factors {
          label
        }
      }
    }
  }
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
