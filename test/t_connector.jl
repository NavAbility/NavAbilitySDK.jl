using DistributedFactorGraphs, IncrementalInference, RoME
using NavAbilitySDK 
using Test

# Not a fully-fledged DFG, but good enough to pass into IncrementalInference
struct DfgDuplicator{T <: AbstractParams, U <: AbstractParams} <: AbstractDFG{T}
  localFg::AbstractDFG{T}
  cloudFg::CloudDFG{U}
  pollingActive::Base.RefValue{Bool}
end

import Base: show
function Base.show(io::IO, duplicator::DfgDuplicator)
  println(io, "Local: ", duplicator.localFg)
  println(io, "\n  Cloud: ", duplicator.cloudFg)
end
Base.show(io::IO, ::MIME"text/plain", duplicator::DfgDuplicator) = show(io, duplicator)

function DfgDuplicator(localFg::AbstractDFG{T}, cloudFg::CloudDFG{U}) where {T <: AbstractParams, U <: AbstractParams}
  return DfgDuplicator{T, U}(localFg, cloudFg, Ref(true))
end

function DfgDuplicator()
  dfg = initfg()
  cfg = CloudDFG(; guestMode=true, solverParams=SolverParams(graphinit=false))
  return DfgDuplicator(dfg, cfg)
end

duplicator = DfgDuplicator()

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



