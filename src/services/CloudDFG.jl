
"""
  $(SIGNATURES)
Completes a interactive login flow and returns a token.
"""
function login()::String
  print("Please login via the NavAbility app")
  auth_url = "https://auth.$(nvaEnv()).navability.io/login?response_type=token&client_id=$(nvaCognitoClient())&redirect_uri=https://app.navability.io/showtoken&state=STATE&scope=openid+profile"
  os_open(auth_url)
  print("Copy the ID token here: ")
  return readline()
end

#### ---- AbstractDFG Functions ---- ####

## See DFG common API layer here
# https://github.com/JuliaRobotics/DistributedFactorGraphs.jl/blob/master/src/services/AbstractDFG.jl#L211-L309

# adding DFG. to explicitly show we are overloading from `const DFG = DistributedFactorGraphs`
# In Julia we take shortcut wi, in Python, JS, we will work 
function addVariable!(dfg::CloudDFG, variable::AbstractDFGVariable)
  return addVariable!(dfg.client, dfg.userId, dfg.robotId, dfg.sessionId, packVariable(dfg, variable))
end

function addFactor!(dfg::CloudDFG, factor::AbstractDFGFactor)
  addFactor!(dfg.client, dfg.userId, dfg.robotId, dfg.sessionId, packFactor(dfg, factor))
end

function copyGraph!(destDFG::CloudDFG,
                    sourceDFG::AbstractDFG,
                    variableLabels::Vector{Symbol},
                    factorLabels::Vector{Symbol};
                    copyGraphMetadata::Bool=false,
                    overwriteDest::Bool=false,
                    deepcopyNodes::Bool=false,
                    verbose::Bool = true)
  # Split into variables and factors
  sourceVariables = map(vId->getVariable(sourceDFG, vId), variableLabels)
  sourceFactors = map(fId->getFactor(sourceDFG, fId), factorLabels)

  # Now we have to add all variables first,
  for variable in sourceVariables
    variableCopy = deepcopyNodes ? deepcopy(variable) : variable
    if !exists(destDFG, variable)
        addVariable!(destDFG, variableCopy)
    elseif overwriteDest
        updateVariable!(destDFG, variableCopy)
    else
        error("Variable $(variable.label) already exists in destination graph!")
    end
  end
  # And then all factors to the destDFG.
  for factor in sourceFactors
    # Get the original factor variables (we need them to create it)
    sourceFactorVariableIds = getNeighbors(sourceDFG, factor)
    # Find the labels and associated variables in our new subgraph
    factVariableIds = Symbol[]
    for variable in sourceFactorVariableIds
      if exists(destDFG, variable)
          push!(factVariableIds, variable)
      end
    end
    # Only if we have all of them should we add it (otherwise strange things may happen on evaluation)
    if length(factVariableIds) == length(sourceFactorVariableIds)
      factorCopy = deepcopyNodes ? deepcopy(factor) : factor
      if !exists(destDFG, factor)
          addFactor!(destDFG, factorCopy)
      elseif overwriteDest
          updateFactor!(destDFG, factorCopy)
      else
          error("Factor $(factor.label) already exists in destination graph!")
      end
    elseif verbose
      @warn "Factor $(factor.label) will be an orphan in the destination graph, and therefore not added."
    end
  end

  if copyGraphMetadata
    setUserData(destDFG, getUserData(sourceDFG))
    setRobotData(destDFG, getRobotData(sourceDFG))
    setSessionData(destDFG, getSessionData(sourceDFG))
  end
  return nothing
end