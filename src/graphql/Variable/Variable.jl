include("PPE.jl")
include("SolverData.jl")

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
  blobEntries {
    ...blobEntry_fields
  }
  variableType
  _version
}
"""

GQL_FRAGMENT_VARIABLES = """
$(GQL_FRAGMENT_SOLVERDATA)
$(GQL_FRAGMENT_VARIABLES_SKELETON)
$(GQL_FRAGMENT_VARIABLES_SUMMARY)
fragment variable_full_fields on Variable {
  metadata
  solvable
  solverData
  {
    ...solverdata_fields
  }
}
"""

# Variables 
GQL_GET_VARIABLE = """
$(GQL_FRAGMENT_VARIABLES)
query get_variable(
  \$userId: ID!
  \$robotId: ID!
  \$sessionId: ID!
  \$variableLabel: String!
  \$fields_summary: Boolean! = true
  \$fields_full: Boolean! = true
) {
  users(where: { id: \$userId }) {
    robots(where: { id: \$robotId }) {
      sessions(where: { id: \$sessionId }) {
        variables(where: { label_MATCHES: \$variableLabel }) {
          ...variable_skeleton_fields
          ...variable_summary_fields @include(if: \$fields_summary)
          ...variable_full_fields @include(if: \$fields_full)
        }
      }
    }
  }
}
"""

# TODO not used yet
GQL_GET_VARIABLES_BY_LABELS = """
$(GQL_FRAGMENT_VARIABLES)
query get_variable(
  \$userId: ID!
  \$robotId: ID!
  \$sessionId: ID!
  \$variableLabels: [String!]!
  \$fields_summary: Boolean! = true
  \$fields_full: Boolean! = true
) {
  users(where: { id: \$userId }) {
    robots(where: { id: \$robotId }) {
      sessions(where: { id: \$sessionId }) {
        variables(where: { label_IN: \$variableLabels }) {
          ...variable_skeleton_fields
          ...variable_summary_fields @include(if: \$fields_summary)
          ...variable_full_fields @include(if: \$fields_full)
        }
      }
    }
  }
}
"""

GQL_GET_VARIABLES = """
$(GQL_FRAGMENT_VARIABLES)
query get_variables(
  \$userId: ID!
  \$robotId: ID!
  \$sessionId: ID!
  \$fields_summary: Boolean! = true
  \$fields_full: Boolean! = true
) {
  users(where: { id: \$userId }) {
    robots(where: { id: \$robotId }) {
      sessions(where: { id: \$sessionId }) {
        variables {
          ...variable_skeleton_fields
          ...variable_summary_fields @include(if: \$fields_summary)
          ...variable_full_fields @include(if: \$fields_full)
        }
      }
    }
  }
}
"""

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

GQL_LIST_VARIABLES = """
query list_variables(\$userId: ID!, \$robotId: ID!, \$sessionId: ID!) {
  users(where: { id: \$userId }) {
    robots(where: { id: \$robotId }) {
      sessions(where: { id: \$sessionId }) {
        variables {
          label
        }
      }
    }
  }
}
"""

##

#TODO not used yet
GQL_GET_VARIABLES_FILTERED = """
$(GQL_FRAGMENT_VARIABLES)
query sdk_get_variables_filtered(
  \$userId: ID!
  \$robotId: ID!
  \$sessionId: ID!
  \$variable_label_regexp: String = ".*"
  \$variable_tags: [String] = ["VARIABLE"]
  \$solvable: Int! = 0
  \$fields_summary: Boolean! = false
  \$fields_full: Boolean! = false
) {
  users(where: { id: \$userId }) {
    robots(where: { id: \$robotId }) {
      sessions(where: { id: \$sessionId }) {
        variables(
          where: {
            label_MATCHES: \$variable_label_regexp
            tags: \$variable_tags
            solvable_GTE: \$solvable
          }
          options: { sort: [{ label: ASC }] }
        ) {
          ...variable_skeleton_fields
          ...variable_summary_fields @include(if: \$fields_summary)
          ...variable_full_fields @include(if: \$fields_full)
        }
      }
    }
  }
}
"""

# TODO 

# GQL_LIST_VARIABLE_NEIGHBORS = """
#   query sdk_list_variable_neighbors (
#     \$userLabel: String!, 
#     \$robotLabel: String!, 
#     \$sessionLabel: String!, 
#     \$variableLabel: String!
#     ) {
#     users(where:{label: \$userLabel}) {
#       robots(where:{label: \$robotLabel}) {
#         sessions(where:{label: \$sessionLabel}) {
#           variables(where:{label: \$variableLabel}) {
#             factors {
#               label
#             }
#           }
#         }
#       }
#     }
#   }"""

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

# GQL_DELETE_VARIABLE = """
# mutation sdk_delete_variables(\$where: VariableWhere) {
#   deleteVariables(
#     where: \$where
#   ) {
#     nodesDeleted
#   }
# }
# """
