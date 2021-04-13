# The {T <: AbstractParams} is the generic solver parameters. 
# I don't think we need it for the moment, but the signature needs it.
mutable struct CloudDFG{T <: AbstractParams} <: AbstractDFG{T}
  client::NavAbilityAPIClient
  # These are standard across all DFG's. I think you might 
  # want to change this, which is not a problem at all.
  userId::String
  robotId::String
  sessionId::String
  description::String
end

# default constructor helper
function CloudDFG(; host::String="https://api.$(nvaEnv()).navability.io/graphql", 
          token::Union{Nothing, <:AbstractString}=nothing,
          robotId::String="DemoRobot",
          sessionId::String="Session_$(string(uuid4())[1:6])")
  if token === nothing
    token = login()
  end
  claims = extractJwtClaims(token)
  !haskey(claims, "cognito:username") && error("Token does not have cognito:username claim")  
  userId = claims["cognito:username"]
  return CloudDFG{NoSolverParams}(NavAbilityAPIClient(;host=host, token=token), userId, robotId, sessionId, "CloudDFG connection to $(host) and data from $(userId):$(robotId):$(sessionId)")
end 

function Base.show(io::IO, dfg::CloudDFG)
  summary(io, dfg)
  println(io, "\n  Host: ", dfg.client.host)
  println(io, "\n  UserId: ", dfg.userId)
  println(io, "  RobotId: ", dfg.robotId)
  println(io, "  SessionId: ", dfg.sessionId)
  println(io, "  Description: ", dfg.description)
end
Base.show(io::IO, ::MIME"text/plain", dfg::CloudDFG) = show(io, dfg)
