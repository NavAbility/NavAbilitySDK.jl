GQL_FRAGMENT_VARIABLES = """
  fragment ppe_fields on PPE {
    solveKey
    suggested
    max
    mean
    lastUpdatedTimestamp {formatted}
  }
  fragment solverdata_fields on SOLVERDATA {
    solveKey
    BayesNetOutVertIDs
    BayesNetVertID
    dimIDs
    dimbw
    dims
    dimval
    dontmargin
    eliminated
    infoPerCoord
    initialized
    ismargin
    separator
    solveInProgress
    solvedCount
    variableType
    vecbw
    vecval
    _version  
  }
  fragment variable_skeleton_fields on VARIABLE {
    label
    tags
  }
  fragment variable_summary_fields on VARIABLE {
    timestamp {formatted}
    ppes {
      ...ppe_fields
    }
    variableType
    _version
    _id
  }
  fragment variable_full_fields on VARIABLE{
    smallData
    solvable
    solverData
    {
      ...solverdata_fields
    }
  }
  """

GQL_GETVARIABLE = """
  query sdk_get_variable(
      \$userId: ID!, 
      \$robotId: ID!, 
      \$sessionId: ID!,
      \$label: ID!) {
    USER(id: \$userId) {
      robots(filter:{id: \$robotId}) {
        sessions(filter:{id: \$sessionId}) {
          variables(filter:{label: \$label}) {
            ...variable_skeleton_fields
            ...variable_summary_fields
            ...variable_full_fields
          }
        }
      }
    }
  }"""

GQL_GETVARIABLES = """
  query sdk_get_variables(
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
          variables {
            ...variable_skeleton_fields
            ...variable_summary_fields @include(if: \$fields_summary)
            ...variable_full_fields @include(if: \$fields_full)
          }
        }
      }
    }
  }"""

GQL_GETVARIABLESFILTERED = """
  query sdk_get_variables_filtered(
      \$userId: ID!, 
      \$robotIds: [ID!]!, 
      \$sessionIds: [ID!]!, 
      \$variable_label_regexp: ID = ".*",
      \$variable_tags: [String!] = ["VARIABLE"],
      \$solvable: Int! = 0,
      \$fields_summary: Boolean! = false, 
      \$fields_full: Boolean! = false){
    USER(id: \$userId) {
      name
      robots(filter:{id_in: \$robotIds}) {
        name
        sessions(filter:{id_in: \$sessionIds}){
          name
          variables(filter:{
              label_regexp: \$variable_label_regexp, 
              tags_contains: \$variable_tags, 
              solvable_gte: \$solvable}) {
            ...variable_skeleton_fields
            ...variable_summary_fields @include(if: \$fields_summary)
            ...variable_full_fields @include(if: \$fields_full)
          }
        }
      }
    }
  }"""
