
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

# function copyGraph!(destDFG::CloudDFG,
#                     sourceDFG::AbstractDFG,
#                     variableLabels::Vector{Symbol},
#                     factorLabels::Vector{Symbol};
#                     copyGraphMetadata::Bool=false,
#                     overwriteDest::Bool=false,
#                     deepcopyNodes::Bool=false,
#                     verbose::Bool = true)

#   # Get a list of the variables+factors in the destination graph
#   client = _gqlClient(destDFG.userId, destDFG.robotId, destDFG.sessionId)
#   results = query(destDFG.client, gql_getNodes(), "getNodes", client)
#   existingVariables = Symbol.(results["VARIABLE"])
#   existingFactors = Symbol.(results["FACTOR"])

#   if !overwriteDest
#     # Only get the stuff that doesn't exist
#     variableLabels = setdiff(variableLabels, existingVariables)
#     factorLabels = setdiff(factorLabels, existingFactors)
#   end

#   sourceVariables = map(vId->getVariable(sourceDFG, vId), variableLabels)
#   sourceFactors = map(fId->getFactor(sourceDFG, fId), factorLabels)
#   # Now we have to add all variables first,
#   for variable in sourceVariables
#     variableCopy = deepcopyNodes ? deepcopy(variable) : variable
#     addVariable!(destDFG, variableCopy)
#   end

#   existingVariables = union(variableLabels, existingVariables)
#   # And then all factors to the destDFG.
#   for factor in sourceFactors
#     # Get the original factor variables (we need them to create it)
#     sourceFactorVariableIds = getNeighbors(sourceDFG, factor.label)
#     # Find the labels and associated variables in our new subgraph
#     factVariableIds = Symbol[]
#     for variable in sourceFactorVariableIds
#       if variable in existingVariables
#           push!(factVariableIds, variable)
#       end
#     end
#     # Only if we have all of them should we add it (otherwise strange things may happen on evaluation)
#     if length(factVariableIds) == length(sourceFactorVariableIds)
#       factorCopy = deepcopyNodes ? deepcopy(factor) : factor
#       addFactor!(destDFG, factorCopy)
#     elseif verbose
#       @warn "Factor $(factor.label) will be an orphan in the destination graph, and therefore not added."
#     end
#   end

#   if copyGraphMetadata
#     setUserData(destDFG, getUserData(sourceDFG))
#     setRobotData(destDFG, getRobotData(sourceDFG))
#     setSessionData(destDFG, getSessionData(sourceDFG))
#   end
#   return nothing
# end

function copyGraph!(destDFG::CloudDFG,
                    sourceDFG::AbstractDFG,
                    variableLabels::Vector{Symbol},
                    factorLabels::Vector{Symbol};
                    copyGraphMetadata::Bool=false,
                    overwriteDest::Bool=false,
                    deepcopyNodes::Bool=false,
                    verbose::Bool = true)

  # Get a list of the variables+factors in the destination graph
  gqlClient = _gqlClient(destDFG.userId, destDFG.robotId, destDFG.sessionId)
  results = query(destDFG.client, gql_getNodes(), "getNodes", gqlClient)
  existingVariables = Symbol.(results["VARIABLE"])
  existingFactors = Symbol.(results["FACTOR"])

  if !overwriteDest
    # Only get the stuff that doesn't exist
    variableLabels = setdiff(variableLabels, existingVariables)
    factorLabels = setdiff(factorLabels, existingFactors)
  end

  variablesToAdd = map(vId->getVariable(sourceDFG, vId), variableLabels)
  sourceFactors = map(fId->getFactor(sourceDFG, fId), factorLabels)

  factorsToAdd = []
  existingVariables = union(variableLabels, existingVariables)
  # And then all factors to the destDFG.
  for factor in sourceFactors
    # Get the original factor variables (we need them to create it)
    sourceFactorVariableIds = getNeighbors(sourceDFG, factor.label)
    # Find the labels and associated variables in our new subgraph
    factVariableIds = intersect(sourceFactorVariableIds, existingVariables)

    # Only if we have all of them should we add it (otherwise strange things may happen on evaluation)
    if symdiff(factVariableIds, sourceFactorVariableIds) == []
      factorCopy = deepcopyNodes ? deepcopy(factor) : factor
      push!(factorsToAdd, factorCopy)
    elseif verbose
      @warn "Factor $(factor.label) will be an orphan in the destination graph, and therefore not added."
    end
  end

  taskId = addSessionData!(
    destDFG.client, 
    gqlClient, 
    [packVariable(destDFG, v) for v in variablesToAdd],
    [packFactor(destDFG, f) for f in factorsToAdd])

  # if copyGraphMetadata
  #   setUserData(destDFG, getUserData(sourceDFG))
  #   setRobotData(destDFG, getRobotData(sourceDFG))
  #   setSessionData(destDFG, getSessionData(sourceDFG))
  # end
  return taskId
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
  return exists(dfg, node.label)
end

function exists(dfg::CloudDFG, label::Symbol)
  client = _gqlClient(dfg.userId, dfg.robotId, dfg.sessionId)
  q = gql_getNodes(String(label))
  @debug "DEBUG: Query = \r\n$q"
  results = query(dfg.client, q, "getNodes", client)
  return length(results["VARIABLE"]) != 0 || length(results["FACTOR"]) != 0
end

"""
    $(SIGNATURES)
Get a DFGVariable from a DFG using its label.
"""
function getVariable(dfg::CloudDFG, 
  label::Union{Symbol, String})
  #
  client = _gqlClient(dfg.userId, dfg.robotId, dfg.sessionId)
  q = gql_getVariables(String(label))
  @debug "DEBUG: Query = \r\n$q"
  results = query(dfg.client, q, "getVariables", client)["VARIABLE"]
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
  q = gql_getFactors(String(label))
  @debug "DEBUG: Query = \r\n$q"
  results = query(dfg.client, q, "getFactors", client)["FACTOR"]
  length(results) == 0 && error("Factor '$label' cannot be found")
  # We have a result, reformat the data so it can be unpacked
  result = results[1]
  result["timestamp"] = result["timestamp"]["formatted"]
  return unpackFactor(dfg, result)
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
function getVariables(dfg::CloudDFG, 
    regexFilter::Union{Nothing, Regex}=nothing; 
    tags::Vector{Symbol}=Symbol[], 
    solvable::Int=0)
  #
  client = _gqlClient(dfg.userId, dfg.robotId, dfg.sessionId)
  q = gql_getVariables(; regexFilter=regexFilter, tags=tags, solvable=solvable)
  @debug "DEBUG: Query = \r\n$q"
  results = query(dfg.client, q, "getVariables", client)["VARIABLE"]
  length(results) == 0 && error("Variables with regex '$regexFilter' and tags '$tags' cannot be found")
  variables = DFGVariable[]
  for v in results
    ##### Data Reformatting section - to be consolidated
    v["timestamp"] = v["timestamp"]["formatted"]
    for ppe in v["ppes"]
      ppe["lastUpdatedTimestamp"] = ppe["lastUpdatedTimestamp"]["formatted"]
    end
    packed = [unmarshal(PackedVariableNodeData, solveData) for solveData in v["solverData"]]
    solverData = map(p -> unpackVariableNodeData(dfg, p), packed)
    ppes = [unmarshal(MeanMaxPPE, p) for p in v["ppes"]]
    ##### Data Reformatting section - to be consolidated
    var = unpackVariable(dfg, v, unpackPPEs=false, unpackSolverData=false, unpackBigData=false)
    [(var.solverDataDict[sd.solveKey] = sd) for sd in solverData]
    [(var.ppeDict[p.solveKey] = p) for p in ppes]
    push!(variables, var)
  end
  return sort!(variables, by=v->v.label)
end

"""
    $(SIGNATURES)
List the DFGFactors in the DFG.
Optionally specify a label regular expression to retrieves a subset of the factors.
"""
function getFactors(dfg::CloudDFG, 
    regexFilter::Union{Nothing, Regex}=nothing; 
    tags::Vector{Symbol}=Symbol[], 
    solvable::Int=0)
  #
  client = _gqlClient(dfg.userId, dfg.robotId, dfg.sessionId)
  q = gql_getFactors(; regexFilter=regexFilter, tags=tags, solvable=solvable)
  @debug "DEBUG: Query = \r\n$q"
  results = query(dfg.client, q, "getFactors", client)["FACTOR"]
  # We have a result, reformat the data so it can be unpacked
  factors = DFGFactor[]
  for f in results
    f["timestamp"] = f["timestamp"]["formatted"]
    push!(factors, unpackFactor(dfg, f))
  end
  return sort!(factors, by=f->f.label)
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
  client = _gqlClient(dfg.userId, dfg.robotId, dfg.sessionId)
  q = gql_getNodes(String(sym))
  @debug "DEBUG: Query = \r\n$q"
  results = query(dfg.client, q, "getNodes", client)
  return length(results["VARIABLE"]) != 0
end

"""
    $SIGNATURES

Return whether `sym::Symbol` represents a factor vertex in the graph DFG.
Checks whether it both exists in the graph and is a factor.
(If you rather want a quicker for type, just do node isa DFGFactor)
"""
function isFactor(dfg::CloudDFG, sym::Symbol)
  client = _gqlClient(dfg.userId, dfg.robotId, dfg.sessionId)
  q = gql_getNodes(String(sym))
  @debug "DEBUG: Query = \r\n$q"
  results = query(dfg.client, q, "getNodes", client)
  return length(results["FACTOR"]) != 0
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

## Cloud-specific functions

""" 
  $(SIGNATURES)

Perform a GraphQL query against the CloudDFG data.
Provide the GQL query as named function(s) (cannot be unnamed for the moment),
and supply the name of the function that should be returned,
as well as any extra arguments needed to execute it.
Note> If you enable debug logging the query and raw response are logged.
"""
function graphQuery(dfg::CloudDFG, q::String, function_name::String, arguments::Dict{String, Any}=Dict{String, Any}())
  args = _gqlClient(dfg.userId, dfg.robotId, dfg.sessionId, arguments)
  @debug "DEBUG: Query = \r\n$q\r\nArguments = \r\nargs"
  result = query(dfg.client, q, function_name, args)
  @debug "DEBUG: Result = \r\n$result"
  return result
end

function solveSession!(dfg::CloudDFG)
  #
  return solveSession!(dfg.client, dfg.userId, dfg.robotId, dfg.sessionId)
end

function solveFederated!(dfg::CloudDFG, solveScope::ScopeInput)
  #
  return solveFederated!(dfg.client, solveScope)
end

function getStatusMessages(dfg::CloudDFG, requestId::String)
  #
  client = _gqlClient(dfg.userId, dfg.robotId, dfg.sessionId)
  q = gql_getStatusMessages(requestId)
  @debug "DEBUG: Query = \r\n$q"
  results = query(dfg.client, q, "getStatusMessages", client)
  return [unmarshal(StatusMessage, m) for m in results["statusMessages"]]
end

function getStatusLatest(dfg::CloudDFG, requestId::String)
  #
  client = _gqlClient(dfg.userId, dfg.robotId, dfg.sessionId)
  q = gql_getStatusLatest(requestId)
  @debug "DEBUG: Query = \r\n$q"
  results = query(dfg.client, q, "getStatusLatest", client)
  if haskey(results, "statusLatest") && results["statusLatest"]["requestId"] == requestId
    return unmarshal(StatusMessage, results["statusLatest"])
  end
  return nothing
end
