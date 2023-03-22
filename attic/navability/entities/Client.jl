import Base: show

"""
$(TYPEDEF)
The context for a session, made from a user, robot, and session.
Users can have multiple robots and robots can have multiple sessions.
So this indicates a unique session.

DevNotes
- TODO, rename possibly, `SessionKey`
"""
Base.@kwdef struct Client
    userId::String
    robotId::String
    sessionId::String
end

function show(io::IO, c::Client)
    print(io, "Client: User=$(c.userId), Robot=$(c.robotId), Session=$(c.sessionId)")
end

"""
$(TYPEDEF)
Some calls interact across multiple users, robots, and sessions.
A scope allows you to specify these more complex contexts.
"""
struct Scope
    environmentIds::Vector{String}
    userIds::Vector{String}
    robotIds::Vector{String}
    sessionIds::Vector{String}
end