GQL_FRAGMENT_FACTORS_SKELETON = """
fragment factor_skeleton_fields on Factor {
  id
  label
  tags
  _variableOrderSymbols
}
"""

GQL_FRAGMENT_FACTORS_SUMMARY = """
fragment factor_summary_fields on Factor {
  timestamp
  nstime
}
"""

GQL_FRAGMENT_FACTORS = """
$(GQL_FRAGMENT_FACTORS_SKELETON)
$(GQL_FRAGMENT_FACTORS_SUMMARY)
fragment factor_full_fields on Factor {
  fnctype
  solvable
  data
  metadata
  _type
  _version
}
"""

GQL_GET_FACTOR = """
$(GQL_FRAGMENT_FACTORS)
query get_variable(
  \$facId: ID!
  \$fields_summary: Boolean! = true
  \$fields_full: Boolean! = true
) {
  factors(where: { id: \$facId }) {
    ...factor_skeleton_fields
    ...factor_summary_fields @include(if: \$fields_summary)
    ...factor_full_fields @include(if: \$fields_full)
  }
}
"""

GQL_ADD_FACTORS = """
$(GQL_FRAGMENT_FACTORS)
mutation sdk_add_factors(\$factorsToCreate: [FactorCreateInput!]!) {
  createFactors(
    input: \$factorsToCreate
  ) {
    factors {
      ...factor_skeleton_fields
      ...factor_summary_fields
      ...factor_full_fields
    }
  }
}
"""

GQL_GET_FACTORS = """
$(GQL_FRAGMENT_FACTORS)
query sdk_get_factors(
  \$fgId: ID!
  \$fields_summary: Boolean! = true
  \$fields_full: Boolean! = true
) {
  factorgraphs(where: { id: \$fgId }) {
    factors {
      ...factor_skeleton_fields
      ...factor_summary_fields @include(if: \$fields_summary)
      ...factor_full_fields @include(if: \$fields_full)
    }
  }
}
"""

GQL_GET_FACTORS_FILTERED = """
$(GQL_FRAGMENT_FACTORS)
query sdk_get_factors_filtered(
    \$sessionId: ID!,
    \$factor_label_regexp: String = ".*",
    \$factor_tags: [String] = ["FACTOR"],
    \$solvable: Int! = 0,
    \$fields_summary: Boolean! = false, 
    \$fields_full: Boolean! = false){
  factors( where: {
        session: {id: \$sessionId},
        label_MATCHES: \$factor_label_regexp, 
        tags: \$factor_tags, 
        solvable_GTE: \$solvable},
        options: { sort: [{ label: ASC } ]}) {
      ...factor_skeleton_fields
      ...factor_summary_fields @include(if: \$fields_summary)
      ...factor_full_fields @include(if: \$fields_full)
  }
}
"""

GQL_LISTFACTORS = """
query sdk_list_factors(\$fgId: ID!) {
  factorgraphs(where: { id: \$fgId }) {
    factors {
      label
    }
  }
}
"""

GQL_DELETE_FACTOR = GQL.gql"""
mutation deleteFactor($factorId: ID!) {
  deleteFactors(
    where: { id: $factorId }
    delete: {
      blobEntries: {
        where: {
          node: { parentConnection: {Factor: { node: { id: $factorId } } } }
        }
      }
    }
  ) {
    nodesDeleted
    relationshipsDeleted
  }
}
"""

# GQL_UPDATE_FACTOR = """
# $(GQL_FRAGMENT_FACTORS)
# mutation sdk_update_factors(\$where: FactorWhere, \$factorToUpdate: FactorUpdateInput!) {
#   updateFactors(
#     where: \$where,
#     update: \$factorToUpdate
#   ) {
#     factors {
#       ...factor_skeleton_fields
#       ...factor_summary_fields
#       ...factor_full_fields
#     }
#   }
# }
# """

