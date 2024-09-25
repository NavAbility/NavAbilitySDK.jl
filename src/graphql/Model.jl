# =================================================
# Fragments
# =================================================

#TODO replace sesssion
# $GQL_FRAGMENT_SESSION
# sessions { ...session_fields }
FRAGMENT_MODEL = """
$GQL_FRAGMENT_BLOBENTRY
fragment FRAGMENT_MODEL on Model {
  label
  createdTimestamp
  namespace
}
"""

# =================================================
# Operations
# =================================================

# $FRAGMENT_MODEL
QUERY_GET_MODEL = """
query QUERY_GET_MODEL(\$modelId: ID!) {
  models (where: {id: \$modelId}) {
    label
    createdTimestamp
    namespace
  }
}
"""

QUERY_GET_MODELS_ALL = """
$FRAGMENT_MODEL
{
    models {
        ...FRAGMENT_MODEL
    }
}
"""

GQL_ADD_MODEL = """
$FRAGMENT_MODEL
mutation addModel(\$label: String!, \$status: String = "", \$description: String = "") {
  createModels(input: {label: \$label, status: \$status, description: \$description}) {
    models {
        ...FRAGMENT_MODEL
    }
  }
}
"""