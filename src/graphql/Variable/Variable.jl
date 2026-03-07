include("State.jl")

GQL_FRAGMENT_VARIABLES_SKELETON = """
fragment variable_skeleton_fields on Variable {
    id
    label
    tags
  }
"""

GQL_FRAGMENT_VARIABLES_SUMMARY = """
$(GQL_FRAGMENT_PPES)
$(GQL_FRAGMENT_BLOBENTRY)
fragment variable_summary_fields on Variable {
  timestamp
  nstime
  ppes {
    ...ppe_fields
  }
  blobentries {
    ...blobEntry_fields
  }
  variableType
  _version
}
"""

#TODO looks like $(GQL_FRAGMENT_VARIABLES_SKELETON) should be moved to GQL_FRAGMENT_VARIABLES_SUMMARY
GQL_FRAGMENT_VARIABLES = """
$(GQL_FRAGMENT_STATE)
$(GQL_FRAGMENT_VARIABLES_SKELETON)
$(GQL_FRAGMENT_VARIABLES_SUMMARY)
fragment variable_full_fields on Variable {
  metadata
  solvable
  states {
    ...state_fields
  }
}
"""

# Variables 
GQL_GET_VARIABLE = """
$(GQL_FRAGMENT_VARIABLES)
query get_variable(
  \$varId: UUID!
  \$fields_summary: Boolean! = true
  \$fields_full: Boolean! = true
) {
    variables(where: { id: {eq: \$varId }}) {
      ...variable_skeleton_fields
      ...variable_summary_fields @include(if: \$fields_summary)
      ...variable_full_fields @include(if: \$fields_full)
    }
}
"""

GQL_GET_VARIABLES_BY_IDS = """
$(GQL_FRAGMENT_VARIABLES)
query get_variables(
  \$variableIds: [UUID!]!
  \$fields_summary: Boolean! = true
  \$fields_full: Boolean! = true
  ) {
    variables(
      where: {
        id: {in: \$variableIds}
      }
    ) {
      ...variable_skeleton_fields
      ...variable_summary_fields @include(if: \$fields_summary)
      ...variable_full_fields @include(if: \$fields_full)
    }
  }
"""

GQL_GET_VARIABLES = """
$(GQL_FRAGMENT_VARIABLES)
query get_variables(
  \$fgId: UUID!
  \$fields_summary: Boolean! = true
  \$fields_full: Boolean! = true
) {
    graphs(where: { id: {eq: \$fgId} }) {
      variables {
        ...variable_skeleton_fields
        ...variable_summary_fields @include(if: \$fields_summary)
        ...variable_full_fields @include(if: \$fields_full)
      }
  }
}
"""
# TODO profile 
# graphs(where: { id: \$fgId }) {
#   variables {
# vs
# variables(where: {fg: {id: \$fgId}}) {

GQL_ADD_VARIABLES = """
$(GQL_FRAGMENT_VARIABLES)
mutation sdk_add_variables(\$variablesToCreate: [VariableCreateInput!]!) {
  addVariables(input: \$variablesToCreate) {
    variables {
      ...variable_skeleton_fields
      ...variable_summary_fields
      ...variable_full_fields
    }
  }
}
"""

GQL_LIST_VARIABLES = GQL.gql"""
query list_variables($fgId: UUID!, $varwhere: ListWhere = {}) {
  listVariables(fgId: $fgId, where: $varwhere)
}
"""

GQL_EXISTS_VARIABLE_FACTOR_LABEL = GQL.gql"""
query($id: UUID!) {
  variables(where: { id: {eq: $id} }) {
    label
  }
  factors(where: { id: {eq: $id} }) {
    label
  }
}
"""

##

#TODO not used yet # also eg. (where :{AND:[{tags_INCLUDES: "POSE"}, {tags_INCLUDES:"VARIABLE"}]})
# also update to org-fg
# GQL_GET_VARIABLES_FILTERED = """
# $(GQL_FRAGMENT_VARIABLES)
# query sdk_get_variables_filtered(
#   \$userId: UUID!
#   \$robotId: UUID!
#   \$sessionId: UUID!
#   \$variable_label_regexp: String = ".*"
#   \$variable_tags: [String] = ["VARIABLE"]
#   \$solvable: Int! = 0
#   \$fields_summary: Boolean! = false
#   \$fields_full: Boolean! = false
# ) {
#   users(where: { id: \$userId }) {
#     robots(where: { id: \$robotId }) {
#       sessions(where: { id: \$sessionId }) {
#         variables(
#           where: {
#             label_MATCHES: \$variable_label_regexp
#             tags: \$variable_tags
#             solvable_GTE: \$solvable
#           }
#           options: { sort: [{ label: ASC }] }
#         ) {
#           ...variable_skeleton_fields
#           ...variable_summary_fields @include(if: \$fields_summary)
#           ...variable_full_fields @include(if: \$fields_full)
#         }
#       }
#     }
#   }
# }
# """

GQL_DELETE_VARIABLE = GQL.gql"""
mutation deleteVariable($variableId: UUID!) {
  deleteVariables(
    where: { id: {eq: $variableId} }
    delete: {
      ppes: {
        where: { node: { variableConnection: { node: { id: {eq: $variableId} } } } }
      }
      states: {
        where: { node: { variableConnection: { node: { id: {eq: $variableId} } } } }
      }
      blobentries: {
        where: { node: { parentConnection: {Variable: {node: {id: {eq: $variableId} } } } } }
      }
      factors: {
        where: { node: { variablesConnection_SOME: {node: {id: {eq: $variableId} } } } } 
      }
    }
  ) {
    nodesDeleted
    relationshipsDeleted
  }
}
"""

GQL_LIST_NEIGHBORS = GQL.gql"""
query listNeighbors(
  $id: UUID!
) {
  variables( where: {id: {eq: $id}}) {
    factors {
      label
    }
  }
  factors( where: {id: {eq: $id}}) {
    variables {
      label
    }
  }
}
"""

GQL_FIND_VARIABLES_NEAR_TIMESTAMP = GQL.gql"""
query findVariablesNearTime(
  $fgId: UUID!
  $fromTime: DateTime!
  $toTime: DateTime!
) {
  graphs(where: { id: {eq: $fgId} }) {
    variables(
      where: {
        AND: [{ timestamp_GT: $fromTime }, { timestamp_LT: $toTime }]
      }
    ) {
      label
    }
  }
}
"""

# TODO 

# GQL_UPDATE_VARIABLE = """
# $(GQL_FRAGMENT_VARIABLES)
# mutation sdk_update_variables(\$where: VariableWhere, \$variableToUpdate: VariableUpdateInput!) {
#   updateVariables(
#     where: \$where,
#     update: \$variableToUpdate
#   ) {
#     variables {
#       ...variable_skeleton_fields
#       ...variable_summary_fields
#       ...variable_full_fields
#     }
#   }
# }
# """
