# =================================================
# Fragments
# =================================================

FRAGMENT_MAP = """
$GQL_FRAGMENT_SESSION
$GQL_FRAGMENT_BLOBENTRY
fragment FRAGMENT_MAP on Map {
  id
  label
  description
  status
  data
  thumbnailId
  exportedMapId 
  sessions { ...session_fields }
  createdTimestamp
  lastUpdatedTimestamp
  blobEntries { ...blobEntry_fields }
}
"""

# =================================================
# Operations
# =================================================

QUERY_GET_MAPS = """
$FRAGMENT_MAP
query QUERY_GET_MAPS(\$userId: ID!) {
  users (where: {id: \$userId}) {
    maps {
        ...FRAGMENT_MAP
    }
  }
}
"""

QUERY_GET_MAPS_ALL = """
$FRAGMENT_MAP
{
    maps {
        ...FRAGMENT_MAP
    }
}
"""

QUERY_GET_MAP = """
$FRAGMENT_MAP
query QUERY_GET_MAP(\$mapId: ID!) {
  maps (where: {id: \$mapId}) {
        ...FRAGMENT_MAP
  }
}
"""

GQL_ADD_MAP = """
$FRAGMENT_MAP
mutation addMAP(\$label: String!, \$status: String = "", \$description: String = "") {
  addMaps(input: {label: \$label, status: \$status, description: \$description}) {
    maps {
        ...FRAGMENT_MAP
    }
  }
}
"""