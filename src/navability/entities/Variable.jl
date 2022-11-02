using Dates
using JSON

DFG_VERSION = "0.18.1";

@enum VariableType begin
    POINT2
    POINT3
    POSE2
    POSE2Z
    POSE3
end

# FIXME, use dispatch for proper Julian implementation
_variableTypeConvert = Dict{Symbol, String}(
    :Point2 => "RoME.Point2",
    :Pose2 => "RoME.Pose2",
    :Pose3 => "RoME.Pose3",
    :ContinuousScalar => "IncrementalInference.ContinuousScalar",
    # TBD - https://github.com/JuliaRobotics/Caesar.jl/discussions/807
    :Position1 => "IncrementalInference.ContinuousScalar",
    #TODO deprecate
    :Pose1 => "IncrementalInference.ContinuousScalar"
)

Base.@kwdef struct Variable
    label::String
    dataEntry::String      = "{}"
    nstime::String         = "0"
    variableType::String
    dataEntryType::String  = "{}"
    ppeDict::String        = "{}"
    solverDataDict::String
    smallData::String      = "{}"
    solvable::Int          = 1
    tags::String
    timestamp::String      = string(now(Dates.UTC))*"Z" # string(now(TimeZones.localzone()))
    _version::String       = DFG_VERSION
end

Base.@kwdef struct SolverDataDict
    vecval::Vector{Float64}     = zeros(0) # FIXME, this is a waste, init can happen on receive side
    dimval::Int
    vecbw::Vector{Float64}      = zeros(dimval)
    dimbw::Int                  = dimval
    BayesNetOutVertIDs::Vector{Int}= []
    dimIDs::Vector{Int}         = collect(range(0,dimval-1, step=1))
    dims::Int                   = dimval
    eliminated::Bool            = false
    BayesNetVertID::String      = "_null"
    separator::Vector{Int}      = []
    variableType::String
    initialized::Bool           = false
    infoPerCoord::Vector{Float64}= zeros(dimval)
    ismargin::Bool              = false
    dontmargin::Bool            = false
    solveInProgress::Int        = 0
    solvedCount::Int            = 0
    solveKey::String
end
function SolverDataDict(variableType::String, solveKey::String, dimval::Int)
    return SolverDataDict(;
        vecval=zeros(dimval*100), # FIXME, this is a waste, numerics can happen on receiver side
        dimval,
        variableType,
        solveKey)
end

"""
Internal utility function to create the correct solver data (variable data)
given a variable type.
"""
function _getSolverDataDict(variableType::String, solveKey::String)::SolverDataDict
    # TODO impove to Julian dispatch
    if variableType == "IncrementalInference.ContinuousScalar"
        return SolverDataDict(variableType, solveKey, 1)
    elseif variableType == "RoME.Point2"
        return SolverDataDict(variableType, solveKey, 2)
    elseif variableType == "RoME.Pose2"
        return SolverDataDict(variableType, solveKey, 3)
    elseif variableType == "RoME.Pose3"
        return SolverDataDict(variableType, solveKey, 6)
    end
    throw(error("Variable type '$(variableType)' not supported."))
end

function VariableKey(
    userId::AbstractString,
    robotId::AbstractString,
    sessionId::AbstractString,
    variableLabel::AbstractString
  )
  #
  Dict{String,String}(
    "userId" => userId,
    "robotId" => robotId,
    "sessionId" => sessionId,
    "variableLabel" => variableLabel
  )
end

function VariableId(
    variableKey
  )
  #
  Dict{String,Any}(
    "key" => variableKey
  )
end

function CartesianPointInput(;
        x::Float64 = 0.0,
        y::Float64 = 0.0,
        z::Float64 = 0.0,
        rotx::Float64 = 0.0,
        roty::Float64 = 0.0,
        rotz::Float64 = 0.0
    )
    #
    Dict{String,Float64}(
        "x" => x,
        "y" => y,
        "z" => z,
        "rotx" => rotx,
        "roty" => roty,
        "rotz" => rotz,
    )
end

function DistributionInput(;
        particle=nothing,
        rayleigh=nothing
    )
    #
    Dict{String,Any}(
        (particle isa Nothing ? () : ("particle"=>particle,))...,
        (rayleigh isa Nothing ? () : ("rayleigh"=>rayleigh,))...
    )
end

# struct InitVariableInput
#     id
#     variableType
#     distribution
#     bandwidth
# end
function InitVariableInput(id,variableType,dstr,bw::AbstractVector=[])
    Dict{String,Any}(
        "id"=>id,
        "variableType"=>variableType,
        "distribution"=>dstr,
        (0<length(bw) ? ("bandwidth"=>bw,) : ())...
    )
end