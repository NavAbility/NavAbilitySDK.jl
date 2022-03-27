GQL_GETSTATUSMESSAGES = """
query sdk_ls_statusmessages(\$id: ID!) {
    statusMessages(id: \$id) {
        requestId,
        action,
        state,
        timestamp,
        client {
            userId,
            robotId,
            sessionId
        }
    }
}
"""

GQL_GETSTATUSLATEST = """
query sdk_get_statuslatest(\$id: ID!) {
  statusLatest(id: \$id) {
    requestId,
    action,
    state,
    timestamp,
    client {
      userId,
      robotId,
      sessionId
    }
  }
}
"""
