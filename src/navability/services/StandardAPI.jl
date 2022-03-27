# Wrap to standard API spec


function NavAbilityPlatform(;
      apiUrl::AbstractString="https://api.d1.navability.io",
      UserId::AbstractString="Guest",
      RobotId::AbstractString=ENV["USER"],
      SessionId::AbstractString="Session_" * string(uuid4())[1:8])
  #
  navability_client = NavAbilityHttpsClient(apiUrl)
  client = Client(UserId, RobotId, SessionId)
  NavAbilityPlatform(navability_client, client)
end

"""
    addVariable

Add a variable to the NavAbility Platform service

Example
```julia
nva = NavAbilityPlatform()

addVariable(nva, "x0", NVA.Pose2)
```
"""
function addVariable(
      nva::NavAbilityPlatform, 
      lbl::Union{<:AbstractString,Symbol},
      varType::Union{<:AbstractString,Symbol} )
  #
  
  v = Variable(string(lbl), Symbol(varType))
  addVariable(nva.navability_client, nva.client, v)
end

# function addFactor(
#       nva::NavAbilityPlatform,
#       vlbls::Union{<:AbstractVector{<:AbstractString}, <:AbstractVector{Symbol}},
#       fct)
#   #
#   WIP
# end