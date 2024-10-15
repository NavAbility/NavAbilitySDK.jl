Base.@kwdef struct Session
    id::UUID
    label::String
    robotLabel::String
    userLabel::String
    _version::String
    createdTimestamp::String# = string(now())
    lastUpdatedTimestamp::String
end

Base.@kwdef struct Robot
    id::UUID
    label::String
    _version::String
    createdTimestamp::String
    lastUpdatedTimestamp::String
    sessions::Vector{Session}
end

function Robot(
    id::UUID,
    label::String,
    _version::String,
    createdTimestamp::String,
    lastUpdatedTimestamp::String,
    ::Nothing,
)
    return Robot(id, label, _version, createdTimestamp, lastUpdatedTimestamp, Session[])
end

Base.@kwdef struct User
    id::UUID
    label::String
    _version::String
    createdTimestamp::String
    lastUpdatedTimestamp::String
    robots::Vector{Robot}
end

function User(
    id::UUID,
    label::String,
    _version::String,
    createdTimestamp::String,
    lastUpdatedTimestamp::String,
    ::Nothing,
)
    return User(id, label, _version, createdTimestamp, lastUpdatedTimestamp, Robot[])
end

# These are required to do anything with a DFG.
Base.@kwdef struct Context
    user::User
    robot::Robot
    session::Session
end

function Base.show(io::IO, ::MIME"text/plain", c::Context)
    summary(io, c)
    println(io)
    println(io, "  userLabel: ", c.user.label)
    println(io, "  robotLabel: ", c.robot.label)
    println(io, "  sessionLabel: ", c.session.label)
    return
end

StructTypes.StructType(::Type{User}) = StructTypes.Struct()
StructTypes.StructType(::Type{Robot}) = StructTypes.Struct()
StructTypes.StructType(::Type{Session}) = StructTypes.Struct()

## Sessions
# Used by create and update
struct SessionResponse
    sessions::Vector{Session}
end

struct RobotResponse
    robots::Vector{Robot}
end
