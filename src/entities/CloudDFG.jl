# The {T <: AbstractParams} is the generic solver parameters. 
# I don't think we need it for the moment, but the signature needs it.
mutable struct CloudDFG{T <: AbstractParams} <: AbstractDFG{T}
  client::NavAbilityAPIClient
  # These are standard across all DFG's. I think you might 
  # want to change this, which is not a problem at all.
  solverParams::T # Solver parameters
  userId::String
  robotId::String
  sessionId::String
  description::String
end

# default constructor helper
"""
    $(SIGNATURES)
Initialize a CloudDFG.
Optional parameters:
- guestMode: If true then the user is 'Guest' and no token is used
- token: A token, or if none is provided and !guestMode, a browser will be opened to login
- solverParams: Must be a SolverParams if you want to interact with IncrementalInference
- robotId/sessionId: Specify the robot ID and the sessionId for the driver. This can be changed as needed
- host: Can direct the CloudDFG to different various environments
Notes
- Return `Vector{Symbol}`
"""
function CloudDFG(; host::String="https://api.$(nvaEnv()).navability.io/graphql", 
          guestMode::Bool=false,
          token::Union{Nothing, <:AbstractString}=nothing,
          solverParams::T=NoSolverParams(),
          robotId::String="DemoRobot",
          sessionId::String="Session_$(string(uuid4())[1:6])") where T
  token = ""
  userId = "Guest"
  if !guestMode
    if token === nothing
      token = login()
    end
    claims = extractJwtClaims(token)
    !haskey(claims, "cognito:username") && error("Token does not have cognito:username claim")  
    userId = claims["cognito:username"]
  end
  return CloudDFG{T}(NavAbilityAPIClient(;host=host, token=token), solverParams, userId, robotId, sessionId, "CloudDFG connection to $(host) and data from $(userId):$(robotId):$(sessionId)")
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
