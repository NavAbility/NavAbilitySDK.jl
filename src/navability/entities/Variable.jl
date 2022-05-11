using Dates
using JSON

DFG_VERSION = "0.18.1";

_variableTypeConvert = Dict{Symbol, String}(
    :Point2 => "RoME.Point2",
    :Pose2 => "RoME.Pose2",
    :ContinuousScalar => "IncrementalInference.ContinuousScalar",
    # TBD - https://github.com/JuliaRobotics/Caesar.jl/discussions/807
    :Position1 => "IncrementalInference.ContinuousScalar",
    #TODO deprecate
    :Pose1 => "IncrementalInference.ContinuousScalar"
)

struct Variable
    label::String
    dataEntry::String
    nstime::String
    variableType::String
    dataEntryType::String
    ppeDict::String
    solverDataDict::String
    smallData::String
    solvable::Int
    tags::String
    timestamp:: String
    _version::String
end

struct SolverDataDict
    vecval::Vector{Float64}
    dimval::Int
    vecbw::Vector{Float64}
    dimbw::Int
    BayesNetOutVertIDs::Vector{Int}
    dimIDs::Vector{Int}
    dims::Int
    eliminated::Bool
    BayesNetVertID::String
    separator::Vector{Int}
    variableType::String
    initialized::Bool
    infoPerCoord::Vector{Float64}
    ismargin::Bool
    dontmargin::Bool
    solveInProgress::Int
    solvedCount::Int
    solveKey::String
end
function SolverDataDict(variableType::String, solveKey::String, dims::Int)
    return SolverDataDict(            
        zeros(dims*100),
        dims,
        zeros(dims),
        dims,   
        [],
        collect(range(0,dims-1, step=1)),
        dims,
        false,
        "_null",
        [],
        variableType,
        false,
        zeros(dims),
        false,
        false,
        0,
        0,
        solveKey)
end

"""
Internal utility function to create the correct solver data (variable data)
given a variable type.
"""
function _getSolverDataDict(variableType::String, solveKey::String)::SolverDataDict
    if variableType == "RoME.Point2"
        return SolverDataDict(variableType, solveKey, 2)
    end
    if variableType == "RoME.Pose2"
        return SolverDataDict(variableType, solveKey, 3)
    end
    if variableType == "IncrementalInference.ContinuousScalar"
        return SolverDataDict(variableType, solveKey, 1)
    end
    throw(error("Variable type '$(variableType)' not supported."))
end

function Variable(label::String, type::Union{String, Symbol}, tags::Vector{String} = ["VARIABLE"], timestamp::String = string(now(Dates.UTC))*"Z")::Variable
    variableType = type isa Symbol ? get(_variableTypeConvert, type, Nothing) : type
    type == Nothing && error("Variable type '$(type) is not supported")

    solverDataDict = Dict("default" => _getSolverDataDict(variableType, "default"))
    result = Variable(
        label,
        "{}",
        "0",
        variableType,
        "{}",
        "{}",
        json(solverDataDict),
        "{}",
        1,
        json(tags),
        timestamp,
        DFG_VERSION
    )
    return result
end