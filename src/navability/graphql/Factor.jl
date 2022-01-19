GQL_FRAGMENT_FACTORS = """
  fragment factor_skeleton_fields on FACTOR {
    label
    tags
    _variableOrderSymbols
  }
  fragment factor_summary_fields on FACTOR {
    timestamp {formatted}
    _version
  }
  fragment factor_full_fields on FACTOR {
    fnctype
    solvable
    data
  }
  """

GQL_GETFACTOR = """
  query sdk_get_variable(
      \$userId: ID!, 
      \$robotId: ID!, 
      \$sessionId: ID!,
      \$label: ID!) {
    USER(id: \$userId) {
      robots(filter:{id: \$robotId}) {
        sessions(filter:{id: \$sessionId}) {
          factors(filter:{label: \$label}) {
            ...factor_skeleton_fields
            ...factor_summary_fields
            ...factor_full_fields
          }
        }
      }
    }
  }"""

GQL_GETFACTORS = """
  query sdk_get_factors(
      \$userId: ID!, 
      \$robotId: ID!, 
      \$sessionId: ID!,
      \$fields_summary: Boolean! = false, 
      \$fields_full: Boolean! = false){
    USER(id: \$userId) {
      name
      robots(filter:{id: \$robotId}) {
        name
        sessions(filter:{id: \$sessionId}){
          name
          factors {
            ...factor_skeleton_fields
            ...factor_summary_fields @include(if: \$fields_summary)
            ...factor_full_fields @include(if: \$fields_full)
          }
        }
      }
    }
  }"""

GQL_GETFACTORSFILTERED = """
  query sdk_get_factors(
      \$userId: ID!, 
      \$robotIds: [ID!]!, 
      \$sessionIds: [ID!]!, 
      \$factor_label_regexp: ID = ".*",
      \$factor_tags: [String!] = ["FACTOR"],
      \$solvable: Int! = 0,
      \$fields_summary: Boolean! = false, 
      \$fields_full: Boolean! = false){
    USER(id: \$userId) {
      name
      robots(filter:{id_in: \$robotIds}) {
        name
        sessions(filter:{id_in: \$sessionIds}){
          name
          factors(filter:{
              label_regexp: \$factor_label_regexp, 
              tags_contains: \$factor_tags, 
              solvable_gte: \$solvable}) {
            ...factor_skeleton_fields
            ...factor_summary_fields @include(if: \$fields_summary)
            ...factor_full_fields @include(if: \$fields_full)
          }
        }
      }
    }
  }"""
