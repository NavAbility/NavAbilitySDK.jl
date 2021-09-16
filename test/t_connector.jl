using DistributedFactorGraphs, IncrementalInference, RoME
using NavAbilitySDK 
using Test

import DistributedFactorGraphs: addVariable!, addFactor!
import DistributedFactorGraphs: getVariables, getVariable, getFactors
import DistributedFactorGraphs: getSolverParams, exists, isVariable, ls

##

# Not a fully-fledged DFG, but good enough to pass into IncrementalInference
struct DfgDuplicator{T <: AbstractParams, U <: AbstractParams} <: AbstractDFG{T}
  localFg::AbstractDFG{T}
  cloudFg::CloudDFG{U}
  pollingActive::Base.RefValue{Bool}
  variableQueue::Vector{Symbol}
end

import Base: show
function Base.show(io::IO, duplicator::DfgDuplicator)
  println(io, "Local: ", duplicator.localFg)
  println(io, "\n  Cloud: ", duplicator.cloudFg)
end
Base.show(io::IO, ::MIME"text/plain", duplicator::DfgDuplicator) = show(io, duplicator)

function DfgDuplicator(localFg::AbstractDFG{T}, cloudFg::CloudDFG{U}) where {T <: AbstractParams, U <: AbstractParams}
  return DfgDuplicator{T, U}(localFg, cloudFg, Ref(true), Symbol[])
end

function DfgDuplicator()
  dfg = initfg()
  cfg = CloudDFG(; guestMode=true, solverParams=SolverParams(graphinit=false))
  return DfgDuplicator(dfg, cfg)
end

function addVariable!(dfg::DfgDuplicator, variable::AbstractDFGVariable)
  v = addVariable!(dfg.localFg, variable)
  @async begin
    reqId = addVariable!(dfg.cloudFg, variable)
    @info "Cloud add request ID: $reqId"
  end
  return v
end

function addFactor!(dfg::DfgDuplicator, factor::AbstractDFGFactor)
  f = addFactor!(dfg.localFg, factor)
  @async addFactor!(dfg.cloudFg, factor)
  return f
end

getSolverParams(dfg::DfgDuplicator) = getSolverParams(dfg.localFg)

getVariables(dfg::DfgDuplicator, 
  regexFilter::Union{Nothing, Regex}=nothing; 
  tags::Vector{Symbol}=Symbol[], 
  solvable::Int=0) = getVariables(dfg.localFg, regexFilter, tags=tags, solvable = solvable)

ls(dfg::DfgDuplicator, 
  regexFilter::Union{Nothing, Regex}=nothing; 
  tags::Vector{Symbol}=Symbol[], 
  solvable::Int=0) = ls(dfg.localFg, regexFilter, tags=tags, solvable = solvable)


getVariable(dfg::DfgDuplicator, 
    label::Union{Symbol, String}) = getVariable(dfg.localFg, label)

isVariable(dfg::DfgDuplicator, label::Symbol) = isVariable(dfg.localFg, label)

exists(dfg::DfgDuplicator, label::Symbol) = DFG.exists(dfg.localFg, label)

getFactors(dfg::DfgDuplicator,   
  regexFilter::Union{Nothing, Regex}=nothing; 
  tags::Vector{Symbol}=Symbol[], 
  solvable::Int=0) = getFactors(dfg.localFg, regexFilter, tags=tags, solvable = solvable)



##

duplicator = DfgDuplicator()

generateCanonicalFG_Beehive!(10, dfg = duplicator, graphinit=false)

# generateCanonicalFG_Beehive!(10, dfg = duplicator.localFg, graphinit=false)
# result = copyGraph!(duplicator.cloudFg, duplicator.localFg, ls(duplicator.localFg), lsf(duplicator.localFg), overwriteDest=true)
# solveSession!(duplicator.cloudFg)

##

getStatusLatest(duplicator.cloudFg, "2633bfdb-da3a-474b-a503-6aa5eeeb3a99")

##

function pollLatestCloudSolution(duplicator::DfgDuplicator)
  while duplicator.pollingActive.x
    @info "Polling"
    sleep(3)
  end
  @info "Exiting!"
end

updatingTask = @task pollLatestCloudSolution(duplicator)
schedule(updatingTask)


# Override IncrementalInference.addVariable and addFactor
# function addVariable!(dfg::DfgDuplicator,
#   label::Symbol,
#   varTypeU::Union{T, Type{T}}; 
#   N::Int=getSolverParams(dfg).N,
#   solvable::Int=1,
#   timestamp::Union{DateTime,ZonedDateTime}=now(localzone()),
#   nanosecondtime::Union{Nanosecond,Int64,Nothing}=nothing,
#   dontmargin::Bool=false,
#   labels::Union{Vector{Symbol},Nothing}=nothing,
#   tags::Vector{Symbol}=Symbol[],
#   smalldata=Dict{Symbol, DFG.SmallDataTypes}(),
#   checkduplicates::Bool=true,
#   initsolvekeys::Vector{Symbol}=getSolverParams(dfg).algorithms ) where T<:InferenceVariable
#   #



