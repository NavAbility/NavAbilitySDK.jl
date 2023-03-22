import Base: show

"""
$(TYPEDEF)
NOTE: Not used yet.
A status message from the server indicating the progress of 
a request, e.g. addVariable or solveSession.
"""
struct StatusMessage
    requestId::String
    action::String
    state::String
    timestamp::String
    client::Client

function show(io::IO, s::StatusMessage)
    print(io, """StatusMessage:
    client: $(self.client)
    requestId: $(s.requestId)
    action: $(self.action) 
    state: $(self.state)
    timestamp: $(self.timestamp) 
    """
    )
end