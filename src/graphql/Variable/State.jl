GQL_FRAGMENT_STATE = """
fragment state_fields on State {
  id
  label
  statekind
  belief
  separator
  initialized
  observability
  marginalized
  solves
  type
}
"""

GQL_GET_STATE = """
$(GQL_FRAGMENT_STATE)
query get_state(
  \$id: UUID!
) {
  states(where: { id: {eq: \$id} }) {
    ...state_fields
  }
}
"""

GQL_GET_STATE_ALL = """
$(GQL_FRAGMENT_STATE)
query get_states_all(
  \$id: UUID!
) {
  variables(where: { id: {eq: \$id} }) {
    states {
      ...state_fields
    }
  }
}
"""

GQL_ADD_STATE = """
$(GQL_FRAGMENT_STATE)
mutation addStates(\$states: [StateCreateInput!]!) {
  # Create the new ones
  addStates(
    input: \$states
  ) {
    states {
      ...state_fields
    }
  }
}
"""

GQL_LIST_STATE = """
query listStates(\$id: UUID!) {
  variables (
    where: {id: {eq: \$id}}
  ) {
    states {
      label
    }
  }
}
"""

GQL_UPDATE_STATE = """
$(GQL_FRAGMENT_STATE)
mutation updateState(\$id: UUID!, \$state: StateUpdateInput!) {
  updateStates(
    update: \$state
    where: {id: {eq: \$id}}
  ) {
    states {
      ...state_fields
    }
  }
}
"""

GQL_DELETE_STATE = GQL.gql"""
mutation deleteState($id: UUID!) {
  deleteStates(where: { id: {eq: $id} }) {
    nodesDeleted
  }
}
"""

# GQL_DELETE_STATE_FOR_SESSION = """
# mutation deleteStateForSession(\$sessionId: UUID!, \$label: String!) {
#   deleteStates(
#     where: {
#       label: \$label, 
#       variable: { session: { id: {eq: \$sessionId} } }
#     }) {
#     nodesDeleted
#   }
# }
# """
