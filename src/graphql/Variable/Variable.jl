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

#TODO looks like $(GQL_FRAGMENT_VARIABLES_SKELETON) should be moved to GQL_FRAGMENT_VARIABLES_SUMMARY
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
        variables(where: { label: \$variableLabel }) {
          ...variable_skeleton_fields
          ...variable_summary_fields @include(if: \$fields_summary)
          ...variable_full_fields @include(if: \$fields_full)
        }
      }
    }
  }
}
"""

GQL_GET_VARIABLES_BY_LABELS = """
$(GQL_FRAGMENT_VARIABLES)
query get_variables(
  \$userLabel: String!
  \$robotLabel: String!
  \$sessionLabel: String!
  \$variableLabels: [String!]!
  \$fields_summary: Boolean! = true
  \$fields_full: Boolean! = true
  ) {
    variables(
      where: {
        userLabel: \$userLabel
        robotLabel: \$robotLabel
        sessionLabel: \$sessionLabel
        label_IN: \$variableLabels
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

GQL_EXISTS_VARIABLE_FACTOR_LABEL = GQL.gql"""
query($userId: ID!, $robotId: ID!, $sessionId: ID!, $label: String!) {
  users(where: { id: $userId }) {
    robots(where: { id: $robotId }) {
      sessions(where: { id: $sessionId }) {
        variables(where: { label: $label }) {
          label
        }
        factors(where: { label: $label }) {
          label
        }
      }
    }
  }
}
"""

##

#TODO not used yet # also eg. (where :{AND:[{tags_INCLUDES: "POSE"}, {tags_INCLUDES:"VARIABLE"}]})
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

GQL_DELETE_VARIABLE = GQL.gql"""
mutation deleteVariable($variableId: ID!) {
  deleteVariables(
    where: { id: $variableId }
    delete: {
      ppes: {
        where: { node: { variableConnection: { node: { id: $variableId } } } }
      }
      solverData: {
        where: { node: { variableConnection: { node: { id: $variableId } } } }
      }
      blobEntries: {
        where: {
          node: { parentConnection: {Variable: {node: {id: $variableId } } } }
        }
      }
    }
  ) {
    nodesDeleted
    relationshipsDeleted
  }
}
"""

GQL_DELETE_VARIABLE_BY_LABEL = GQL.gql"""
mutation deleteVariable(
  $userLabel: String!
  $robotLabel: String!
  $sessionLabel: String!
  $variableLabel: String!
) {
  deleteVariables(
    where: {
      userLabel: $userLabel
      robotLabel: $robotLabel
      sessionLabel: $sessionLabel
      label: $variableLabel
    }
    delete: {
      ppes: {
        where: {
          node: {
            variableConnection: {
              node: {
                userLabel: $userLabel
                robotLabel: $robotLabel
                sessionLabel: $sessionLabel
                label: $variableLabel
              }
            }
          }
        }
      }
      solverData: {
        where: {
          node: {
            variableConnection: {
              node: {
                userLabel: $userLabel
                robotLabel: $robotLabel
                sessionLabel: $sessionLabel
                label: $variableLabel
              }
            }
          }
        }
      }
      blobEntries: {
        where: {
          node: {
            parentConnection: {
              Variable: {
                node: {
                  userLabel: $userLabel
                  robotLabel: $robotLabel
                  sessionLabel: $sessionLabel
                  label: $variableLabel
                }
              }
            }
          }
        }
      }
    }
  ) {
    nodesDeleted
    relationshipsDeleted
  }
}
"""

GQL_LIST_VARIABLE_NEIGHBORS = GQL.gql"""
query listVariableNeighbors(
  $userLabel: String!
  $robotLabel: String!
  $sessionLabel: String!
  $variableLabel: String!
) {
  variables(
    where: {
      userLabel: $userLabel
      robotLabel: $robotLabel
      sessionLabel: $sessionLabel
      label: $variableLabel
    }
  ) {
    factors {
      label
    }
  }
}
"""

GQL_LIST_NEIGHBORS = GQL.gql"""
query listNeighbors(
  $userLabel: String!
  $robotLabel: String!
  $sessionLabel: String!
  $nodeLabel: String!
) {
  variables(
    where: {
      userLabel: $userLabel
      robotLabel: $robotLabel
      sessionLabel: $sessionLabel
      label: $nodeLabel
    }
  ) {
    factors {
      label
    }
  }
  factors(
    where: {
      userLabel: $userLabel
      robotLabel: $robotLabel
      sessionLabel: $sessionLabel
      label: $nodeLabel
    }
  ) {
    variables {
      label
    }
  }
}
"""

GQL_FIND_VARIABLES_NEAR_TIMESTAMP = GQL.gql"""
query findVariablesNearTime(
  $userLabel: String!
  $robotLabel: String!
  $sessionLabel: String!
  $fromTime: DateTime!
  $toTime: DateTime!
) {
  variables(
    where: {
      userLabel: $userLabel
      robotLabel: $robotLabel
      sessionLabel: $sessionLabel
      AND: [{ timestamp_GT: $fromTime }, { timestamp_LT: $toTime }]
    }
  ) {
    label
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

