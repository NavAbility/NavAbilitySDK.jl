# =================================================
# Fragments
# =================================================

# [fragments]

FRAGMENT_WORKFLOW = """
fragment FRAGMENT_WORKFLOW on Workflow {
  id
  label
  description
  status
  data
  result
  _type
  _version
  createdTimestamp
  lastUpdatedTimestamp
}
"""

# =================================================
# Operations
# =================================================

# [operations]

# QUERY_GET_WORKFLOWS = """
# query QUERY_GET_WORKFLOWS($userId: ID!, $mapId: ID!) {

# }
# """

# QUERY_GET_WORKFLOW = """
# query QUERY_GET_WORKFLOW($userId: ID!, $mapId: ID!, $workflowId: ID!) {
  
# }
# """