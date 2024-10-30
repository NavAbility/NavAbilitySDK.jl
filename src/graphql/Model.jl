# =================================================
# Fragments
# =================================================

#TODO replace sesssion
# $GQL_FRAGMENT_SESSION
# sessions { ...session_fields }
# $GQL_FRAGMENT_BLOBENTRY
FRAGMENT_MODEL = """
fragment FRAGMENT_MODEL on Model {
  label
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
    namespace
  }
}
"""

# $FRAGMENT_MODEL
# ...FRAGMENT_MODEL
QUERY_GET_MODELS_ALL = """
{
  models {
    label
    namespace
  }
}
"""

GQL_ADD_MODELS = GQL.gql"""
mutation addModels($input: [ModelCreateInput!]!) {
  addModels(input: $input) {
    models {
        label
        namespace
    }
  }
}
"""

QUERY_GET_MODEL_GRAPHS = GQL.gql"""
query getGraphs_Model($id: ID!) {
  models(where: {id: $id}) {
    fgs {
      label
      namespace
    }
  }
}
"""