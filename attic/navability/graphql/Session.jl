
GQL_GET_SESSION = """
query sdk_get_session(
    \$userId: ID!, 
    \$robotId: ID!, 
    \$sessionId: ID!
  ) {
  users(where: {id: \$userId}) {
    id
    robots(where:{id: \$robotId}) {
      id
      sessions(where:{id: \$sessionId}) {
        variables {
          label
        }
        factors {
          label
        }
      }
    }
  }
}
"""

MUTATION_EXPORT_SESSION = """
mutation sdk_export_session(
    \$session: ExportSessionInput!, 
    \$options: ExportSessionOptions
  ){
  exportSession(session:\$session, options:\$options) {
    context {
      eventId
    }
    status {
      state
      progress
    }
  }
}
"""

# get the blobId given the blob upload eventId
GQL_GET_EXPORT_SESSION_COMPLETE_EVENT_BY_ID = """
query events_by_id(\$eventId:String) {
  events(where: {status:{state:Complete}, context:{eventId:\$eventId}}) {
    status {
      state
    }
    data {
      ... on ExportSessionComplete {
        blob {
          id
        }
      }
      ... on AddBlobMetadataComplete {
        blob {
          id
        }
      }
    }
  }
}
"""