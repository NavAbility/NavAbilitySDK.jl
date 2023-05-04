# =================================================
# Fragments
# =================================================

FRAGMENT_VISUALIZATION_BLOB = """
fragment FRAGMENT_VISUALIZATION_BLOB on VisualizationBlob {
  hierarchyId
  octreeId
  metadataId
}
"""

FRAGMENT_ANNOTATION = """
fragment FRAGMENT_ANNOTATION on Annotation {
  id
  # HTML text
  text
  position
}
"""

FRAGMENT_AFFORDANCE = """
fragment FRAGMENT_AFFORDANCE on Affordance {
  id
  label
  position
  rotation
  scale
}
"""

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
$FRAGMENT_VISUALIZATION_BLOB
# FRAGMENT_ANNOTATION
# FRAGMENT_AFFORDANCE
$FRAGMENT_SESSION
# FRAGMENT_WORKFLOW

fragment FRAGMENT_MAP on Map {
  id
  label
  description
  status
  data
  thumbnailId
  visualization { ...FRAGMENT_VISUALIZATION_BLOB }
  exportedMapId 
  # annotations { ...FRAGMENT_ANNOTATION }
  # affordances { ...FRAGMENT_AFFORDANCE }
  sessions { ...FRAGMENT_SESSION }
  # workflows { ...FRAGMENT_WORKFLOW }
  createdTimestamp
  lastUpdatedTimestamp
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
query QUERY_GET_MAP(\$userId: ID!, \$mapId: ID!) {
  users (where: {id: \$userId}) {
    maps (where: {id: \$mapId}) {
        ...FRAGMENT_MAP
    }
  }
}

"""