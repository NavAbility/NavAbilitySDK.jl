
# @enum BagFormat begin
#   NVA # FIXME TARGZ
#   ROS1BAG
#   MCAP
# end


Base.@kwdef struct SessionKey
  userId::String
  robotId::String
  sessionId::String
end

# dictionary since either fields can be used
function SessionId(;
    id::Union{<:AbstractString,Nothing}=nothing,
    key::Union{SessionKey,Nothing}=nothing
  )
  #
  _idorkeys = id isa Nothing
  Dict(
    (_idorkeys ? () : ("id"=>id,))...,
    (!_idorkeys ? () : ("key"=>key,))...
  )
end

Base.@kwdef struct ExportSessionInput
  id::Dict
  filename::String
end

Base.@kwdef struct ExportSessionOptions
  format::String
end