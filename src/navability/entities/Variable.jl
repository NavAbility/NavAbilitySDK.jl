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

function Variable(label::AbstractString, type::Union{<:AbstractString, Symbol}, tags::AbstractVector{<:AbstractString} = ["VARIABLE"], timestamp::String = string(now(Dates.UTC))*"Z")::Variable
    variableType = type isa Symbol ? get(_variableTypeConvert, type, Nothing) : type
    type == Nothing && error("Variable type '$(type) is not supported")

    solverDataDict = Dict("default" => _getSolverDataDict(variableType, "default"))
    result = Variable(;
        label,
        variableType,
        # TODO, should not require jsoning, see DFG#867
        solverDataDict = json(solverDataDict),
        tags = json(tags),
        timestamp
    )
    return result
end