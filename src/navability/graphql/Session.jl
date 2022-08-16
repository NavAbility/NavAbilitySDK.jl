
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
