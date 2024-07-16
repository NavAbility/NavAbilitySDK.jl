# =================================================
# Fragments
# =================================================


FRAGMENT_SESSION = """
fragment FRAGMENT_SESSION on Session {
  id
  label
  originLatitude
  originLongitude
  metadata
  # blobEntries { ...FRAGMENT_BLOBENTRY }
  _version
  createdTimestamp
  lastUpdatedTimestamp
  # variables
  # factors
}
"""

FRAGMENT_MAP = """
$FRAGMENT_SESSION
$GQL_FRAGMENT_BLOBENTRY
fragment FRAGMENT_MAP on Map {
  id
  label
  description
  status
  data
  thumbnailId
  exportedMapId 
  sessions { ...FRAGMENT_SESSION }
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

QUERY_GET_MAP = """
$FRAGMENT_MAP
query QUERY_GET_MAP(\$mapId: ID!) {
  maps (where: {id: \$mapId}) {
        ...FRAGMENT_MAP
  }
}
"""