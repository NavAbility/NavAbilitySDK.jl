struct Client
    userId::String
    robotId::String
    sessionId::String
end

struct Scope
    environmentIds::Vector{String}
    userIds::Vector{String}
    robotIds::Vector{String}
    sessionIds::Vector{String}
end