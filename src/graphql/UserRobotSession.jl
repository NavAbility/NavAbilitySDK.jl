GQL_FRAGMENT_USER = """
fragment user_fields on User {
  id
  label
  _version
  createdTimestamp
  lastUpdatedTimestamp
}
"""

GQL_FRAGMENT_ROBOT = """
fragment robot_fields on Robot {
  id
  label
  _version
  createdTimestamp
  lastUpdatedTimestamp
}
"""

# TODO consolidate with GQL_FRAGMENT_SESSION
# FRAGMENT_SESSION = """
# fragment FRAGMENT_SESSION on Session {
#   id
#   label
#   originLatitude
#   originLongitude
#   metadata
#   # blobEntries { ...FRAGMENT_BLOBENTRY }
#   _version
#   createdTimestamp
#   lastUpdatedTimestamp
#   # variables
#   # factors
# }
# """

GQL_FRAGMENT_SESSION = """
fragment session_fields on Session {
  id
  label
  robotLabel
  userLabel
  _version
  createdTimestamp
  lastUpdatedTimestamp
}
"""

GQL_GET_USER = """
$(GQL_FRAGMENT_USER)
$(GQL_FRAGMENT_ROBOT)
$(GQL_FRAGMENT_SESSION)
query getUser(\$userLabel: EmailAddress!) {
  users (where: {label: \$userLabel}) {
    ...user_fields
    robots {
      ...robot_fields
      sessions {
        ...session_fields
      }  
    }
  }
}"""

GQL_GET_USERROBOTSESSION = """
$(GQL_FRAGMENT_USER)
$(GQL_FRAGMENT_ROBOT)
$(GQL_FRAGMENT_SESSION)
query getURS(\$userLabel: EmailAddress!, \$robotLabel: String!, \$sessionLabel: String!) {
  users (where: {label: \$userLabel}) {
    ...user_fields
    robots (where: {label: \$robotLabel}) {
      ...robot_fields
      sessions (where: {label: \$sessionLabel}) {
        ...session_fields
      }  
    }
  }
}"""

GQL_GET_ROBOT = """
$(GQL_FRAGMENT_USER)
$(GQL_FRAGMENT_ROBOT)
$(GQL_FRAGMENT_SESSION)
query getRobot(\$userLabel: EmailAddress!, \$robotLabel: String!) {
  users(where: { label: \$userLabel }) {
    ...user_fields
    robots(where: { label: \$robotLabel }) {
      ...robot_fields
      sessions {
        ...session_fields
      }
    }
  }
}
"""


GQL_ADD_ROBOT = """
$(GQL_FRAGMENT_ROBOT)
mutation addRobot(
  \$userId: ID!
  \$robotLabel: String!
  \$version: String!
  \$userLabel: String!
) {
  addRobots(
    input: {
      label: \$robotLabel
      userLabel: \$userLabel
      _version: \$version
      user: { connect: { where: { node: { id: \$userId } } } }
    }
  ) {
    robots {
      ...robot_fields
    }
  }
}
"""

GQL_ADD_SESSION = """
$(GQL_FRAGMENT_SESSION)
mutation sdk_add_session(
  \$userLabel: String!
  \$robotLabel: String!
  \$robotId: ID!
  \$sessionLabel: String!
  \$version: String!
) {
  addSessions(
    input: {
      label: \$sessionLabel
      _version: \$version
      userLabel: \$userLabel
      robotLabel: \$robotLabel
      robot: { connect: { where: { node: { id: \$robotId } } } }
    }
  ) {
    sessions {
      ...session_fields
    }
  }
}
"""

GQL_GET_SESSIONS = """
$(GQL_FRAGMENT_SESSION)
query sdk_get_sessions(\$robotId:: ID!)
  sessions (where: {robot: {id: \$robotId}}) {
    ...session_fields
  }
"""

#Only session, force user to delete everthing in session to prevent acedentally deleting everthing?
GQL_DELETE_SESSION = GQL.gql"""
mutation deleteSession($sessionId: ID!) {
  deleteSessions(
    where: { id: $sessionId }
    delete: {
      blobEntries: {
        where: { node: { parentConnection: {Session: {node: {id: $sessionId } } } } }
      }
    }
  ) {
    nodesDeleted
    relationshipsDeleted
  }
}
"""



#Only robot, force user to delete everthing in robot to prevent acedentally deleting everthing?
GQL_DELETE_ROBOT = GQL.gql"""
mutation deleteRobot($robotId: ID!) {
  deleteRobots(
    where: { id: $robotId }
    delete: {
      blobEntries: {
        where: { node: { parentConnection: {Robot: {node: {id: $robotId } } } } }
      }
    }
  ) {
    nodesDeleted
    relationshipsDeleted
  }
}
"""