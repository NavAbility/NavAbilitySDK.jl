GQL_FRAGMENT_FACTORS_SKELETON = """
fragment factor_skeleton_fields on Factor {
  label
  tags
  variableorder
}
"""

GQL_FRAGMENT_FACTORS_SUMMARY = """
$(GQL_FRAGMENT_BLOBENTRY)
fragment factor_summary_fields on Factor {
  timestamp
  blobentries {
    ...blobEntry_fields
  }
}
"""

GQL_FRAGMENT_FACTORS = """
$(GQL_FRAGMENT_FACTORS_SKELETON)
$(GQL_FRAGMENT_FACTORS_SUMMARY)
fragment factor_full_fields on Factor {
  solvable
  type
  observation
  hyper
  state
}
"""

GQL_GET_FACTOR = """
$(GQL_FRAGMENT_FACTORS)
query getFactor(
  \$facId: UUID!
  \$fields_summary: Boolean! = true
  \$fields_full: Boolean! = true
) {
  factors(where: { id: {eq: \$facId} }) {
    ...factor_skeleton_fields
    ...factor_summary_fields @include(if: \$fields_summary)
    ...factor_full_fields @include(if: \$fields_full)
  }
}
"""

GQL_ADD_FACTORS = """
$(GQL_FRAGMENT_FACTORS)
mutation addFactors(\$input: [FactorCreateInput!]!) {
  addFactors(
    input: \$input
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
query getFactors(
  \$fgId: UUID!
  \$fields_summary: Boolean! = true
  \$fields_full: Boolean! = true
) {
  graphs(where: { id: {eq: \$fgId} }) {
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
query getFactors_filtered(
    \$sessionId: UUID!,
    \$factor_label_regexp: String = ".*",
    \$factor_tags: [String] = ["FACTOR"],
    \$solvable: Int! = 0,
    \$fields_summary: Boolean! = false, 
    \$fields_full: Boolean! = false){
  factors( where: {
        session: {id: {eq: \$sessionId}},
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

GQL_LIST_FACTORS = GQL.gql"""
query listFactors($fgId: UUID!, $where: ListWhere = {}) {
  listFactors(fgId: $fgId, where: $where)
}
"""

GQL_DELETE_FACTOR = GQL.gql"""
mutation deleteFactor($factorId: UUID!) {
  deleteFactors(
    where: { id: {eq: $factorId} }
    delete: {
      blobentries: {}
      bloblets: {}
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

QUERY_GET_FACTOR_BLOBLETS = GQL.gql"""
query getFactorBloblets($id: UUID!) {
  factors(where: {id: {eq: $id}}) {
    bloblets {
      label
      val
    }
  }
}
"""

QUERY_ADD_FACTOR_BLOBLET = GQL.gql"""
mutation addFactorBloblet($id: UUID!, $label: String!, $val: String!) {
  addFactorBloblet(FactorId: $id, input: {label: $label, val: $val}) {
    label
    val
  }
}
"""
