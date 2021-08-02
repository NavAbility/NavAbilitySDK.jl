
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

##==============================================================================
## CRUD Interfaces
##==============================================================================
##------------------------------------------------------------------------------
## Variable And Factor CRUD
##------------------------------------------------------------------------------
"""
    $(SIGNATURES)
True if the variable or factor exists in the graph.
"""
function exists(dfg::CloudDFG, node::DFGNode)
  error("exists not implemented for $(typeof(dfg))")
end

function exists(dfg::CloudDFG, label::Symbol)
  error("exists not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
Get a DFGVariable from a DFG using its label.
"""
function getVariable(dfg::CloudDFG, 
  label::Union{Symbol, String})
  #
  client = _gqlClient(dfg.userId, dfg.robotId, dfg.sessionId)
  q = gql_getVariable(String(label))
  @debug "DEBUG: Query = \r\n$q"
  results = query(dfg.client, q, "getVariable", client)["VARIABLE"]
  length(results) == 0 && error("Variable '$label' cannot be found")
  ##### Data Reformatting section - to be consolidated
  result = results[1]
  result["timestamp"] = result["timestamp"]["formatted"]
  for ppe in result["ppes"]
    ppe["lastUpdatedTimestamp"] = ppe["lastUpdatedTimestamp"]["formatted"]
  end
  packed = [unmarshal(PackedVariableNodeData, solveData) for solveData in result["solverData"]]
  solverData = map(p -> unpackVariableNodeData(dfg, p), packed)
  ppes = [unmarshal(MeanMaxPPE, p) for p in result["ppes"]]
  ##### Data Reformatting section - to be consolidated
  v = unpackVariable(dfg, result, unpackPPEs=false, unpackSolverData=false, unpackBigData=false)
  [(v.solverDataDict[sd.solveKey] = sd) for sd in solverData]
  [(v.ppeDict[p.solveKey] = p) for p in ppes]
  return v
end


"""
    $(SIGNATURES)
Get a DFGFactor from a DFG using its label.
"""
function getFactor(dfg::CloudDFG, 
  label::Union{Symbol, String})
  #
  client = _gqlClient(dfg.userId, dfg.robotId, dfg.sessionId)
  q = gql_getFactor(String(label))
  @debug "DEBUG: Query = \r\n$q"
  results = query(dfg.client, q, "getFactor", client)["FACTOR"]
  length(results) == 0 && error("Factor '$label' cannot be found")
  # We have a result, reformat the data so it can be unpacked
  result = results[1]
  result["timestamp"] = result["timestamp"]["formatted"]
  return unpackFactor(dfg, result)
end


function Base.getindex(dfg::AbstractDFG, lbl::Union{Symbol, String})
  if isVariable(dfg, lbl)
      getVariable(dfg, lbl)
  elseif isFactor(dfg, lbl)
      getFactor(dfg, lbl)
  else
      error("Cannot find $lbl in this $(typeof(dfg))")
  end
end

"""
    $(SIGNATURES)
Update a complete DFGVariable in the DFG.
"""
function updateVariable!(dfg::CloudDFG, variable::V) where {V <: AbstractDFGVariable}
  error("updateVariable! not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
Update a complete DFGFactor in the DFG.
"""
function updateFactor!(dfg::CloudDFG, factor::F) where {F <: AbstractDFGFactor}
  error("updateFactor! not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
Delete a DFGVariable from the DFG using its label.
"""
function deleteVariable!(dfg::CloudDFG, label::Symbol)
  error("deleteVariable! not implemented for $(typeof(dfg))")
end
"""
    $(SIGNATURES)
Delete a DFGFactor from the DFG using its label.
"""
function deleteFactor!(dfg::CloudDFG, label::Symbol)
  error("deleteFactors not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
List the DFGVariables in the DFG.
Optionally specify a label regular expression to retrieves a subset of the variables.
Tags is a list of any tags that a node must have (at least one match).
"""
function getVariables(dfg::CloudDFG, regexFilter::Union{Nothing, Regex}=nothing; tags::Vector{Symbol}=Symbol[], solvable::Int=0)
  error("getVariables not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
List the DFGFactors in the DFG.
Optionally specify a label regular expression to retrieves a subset of the factors.
"""
function getFactors(dfg::CloudDFG, regexFilter::Union{Nothing, Regex}=nothing; tags::Vector{Symbol}=Symbol[], solvable::Int=0)
  error("getFactors not implemented for $(typeof(dfg))")
end



##------------------------------------------------------------------------------
## Checking Types
##------------------------------------------------------------------------------

"""
    $SIGNATURES

Return whether `sym::Symbol` represents a variable vertex in the graph DFG.
Checks whether it both exists in the graph and is a variable.
(If you rather want a quick for type, just do node isa DFGVariable)
"""
function isVariable(dfg::CloudDFG, sym::Symbol)
  error("isVariable not implemented for $(typeof(dfg))")
end

"""
    $SIGNATURES

Return whether `sym::Symbol` represents a factor vertex in the graph DFG.
Checks whether it both exists in the graph and is a factor.
(If you rather want a quicker for type, just do node isa DFGFactor)
"""
function isFactor(dfg::CloudDFG, sym::Symbol)
  error("isFactor not implemented for $(typeof(dfg))")
end


##------------------------------------------------------------------------------
## Neighbors
##------------------------------------------------------------------------------
"""
    $(SIGNATURES)
Checks if the graph is fully connected, returns true if so.
"""
function isConnected(dfg::CloudDFG)
  error("isConnected not implemented for $(typeof(dfg))")
end

"""
    $(SIGNATURES)
Retrieve a list of labels of the immediate neighbors around a given variable or factor specified by its label.
"""
function getNeighbors(dfg::CloudDFG, label::Symbol; solvable::Int=0)
  error("getNeighbors not implemented for $(typeof(dfg))")
end


##------------------------------------------------------------------------------
## copy and duplication
##------------------------------------------------------------------------------

#TODO use copy functions currently in attic
"""
    $(SIGNATURES)
Gets an empty and unique CloudGraphsDFG derived from an existing DFG.
"""
function _getDuplicatedEmptyDFG(dfg::CloudDFG)
  error("_getDuplicatedEmptyDFG not implemented for $(typeof(dfg))")
end

## Additional overloads
  
function listVariables(dfg::CloudDFG, 
  regexFilter::Union{Nothing, Regex}=nothing; 
  tags::Vector{Symbol}=Symbol[], 
  solvable::Int=0 )
#
  client = _gqlClient(dfg.userId, dfg.robotId, dfg.sessionId)
  q = gql_ls(regexFilter=regexFilter, tags=tags, solvable=solvable)
  @debug "DEBUG: Query = \r\n$q"
  result = query(dfg.client, q, "ls", client)
  return Symbol.(sort([v["label"] for v in result["VARIABLE"]]))
end


# function listVariables( dfg::CloudDFG, 
#     typeFilter::Type{<:InferenceVariable}; 
#     tags::Vector{Symbol}=Symbol[], 
#     solvable::Int=0 )
# #
#   retlist::Vector{Symbol} = ls(dfg, typeFilter)
#   0 < length(tags) || solvable != 0 ? intersect(retlist, ls(dfg, tags=tags, solvable=solvable)) : retlist
# end

function listFactors(dfg::CloudDFG, 
  regexFilter::Union{Nothing, Regex}=nothing; 
  tags::Vector{Symbol}=Symbol[], 
  solvable::Int=0)::Vector{Symbol}
  #
  client = _gqlClient(dfg.userId, dfg.robotId, dfg.sessionId)
  q = gql_lsf(regexFilter=regexFilter, tags=tags, solvable=solvable)
  @debug "DEBUG: Query = \r\n$q"
  result = query(dfg.client, q, "lsf", client)
  return Symbol.(sort([v["label"] for v in result["FACTOR"]]))
end

# function listSolveKeys( variable::DFGVariable,
#     filterSolveKeys::Union{Regex,Nothing}=nothing,
#     skeys = Set{Symbol}() )
#   #
#   for ky in keys(getSolverDataDict(variable))
#     push!(skeys, ky)
#   end

#   #filter the solveKey set with filterSolveKeys regex
#   !isnothing(filterSolveKeys) && return filter!(k -> occursin(filterSolveKeys, string(k)), skeys)
#   return skeys
# end

# listSolveKeys(  dfg::AbstractDFG, lbl::Symbol,
#     filterSolveKeys::Union{Regex,Nothing}=nothing,
#     skeys = Set{Symbol}() ) = listSolveKeys(getVariable(dfg, lbl), filterSolveKeys, skeys)
# #

# function listSolveKeys( dfg::AbstractDFG, 
#     filterVariables::Union{Type{<:InferenceVariable},Regex, Nothing}=nothing;
#     filterSolveKeys::Union{Regex,Nothing}=nothing,
#     tags::Vector{Symbol}=Symbol[], 
#     solvable::Int=0  )
#   #
#   skeys = Set{Symbol}()
#   varList = listVariables(dfg, filterVariables, tags=tags, solvable=solvable)
#   for vs in varList  #, ky in keys(getSolverDataDict(getVariable(dfg, vs)))
#     listSolveKeys(dfg, vs, filterSolveKeys, skeys)
#   end

#   # done inside the loop
#   # #filter the solveKey set with filterSolveKeys regex
#   # !isnothing(filterSolveKeys) && return filter!(k -> occursin(filterSolveKeys, string(k)), skeys)

#   return skeys
# end