Base.@kwdef struct VariableCreateInput
    label::String
    nstime::String = ""
    variableType::String
    solvable::Int64 = 1
    tags::Vector{String} = ["VARIABLE"]
    metadata::String = "e30="
    _version::String = string(DFG._getDFGVersion())
    timestamp::String = string(now(localzone()))

    userLabel::String
    robotLabel::String
    sessionLabel::String

    ppes::Any = nothing #TODO VariablePpesFieldInput
    blobEntries::Any = nothing #TODO VariableBlobEntriesFieldInput
    solverData::Any = nothing #TODO VariableSolverDataFieldInput
    factors::Any = nothing #TODO VariableFactorsFieldInput
    session::Any #TODO VariableSessionFieldInput
end

function StructTypes.omitempties(::Type{VariableCreateInput})
    return (:ppes, :blobEntries, :solverData, :factors)
end

Base.@kwdef struct PPECreateInput
    solveKey::Symbol
    suggested::Vector{Float64}
    max::Vector{Float64}
    mean::Vector{Float64}
    _type::String = "MeanMaxPPE"
    _version::String = string(DFG._getDFGVersion())

    userLabel::String
    robotLabel::String
    sessionLabel::String
    variableLabel::String

    suggested_cartesian::Any = nothing #TODO PointInput
    max_cartesian::Any = nothing #TODO PointInput
    mean_cartesian::Any = nothing #TODO PointInput
    variable::Any  #TODO PPEVariableFieldInput
end

function StructTypes.omitempties(::Type{PPECreateInput})
    return (:suggested_cartesian, :max_cartesian, :mean_cartesian, :variable)
end

Base.@kwdef struct SolverDataCreateInput
    solveKey::Symbol
    BayesNetOutVertIDs::Vector{Symbol}
    BayesNetVertID::Symbol
    dimIDs::Vector{Int}
    dimbw::Int
    dims::Int
    dimval::Int
    dontmargin::Bool
    eliminated::Bool
    infoPerCoord::Vector{Float64}
    initialized::Bool
    ismargin::Bool
    separator::Vector{String}
    solveInProgress::Int
    solvedCount::Int
    variableType::String
    vecbw::Vector{Float64}
    vecval::Vector{Float64}
    covar::Vector{Float64} = Float64[]
    _version::String

    userLabel::String
    robotLabel::String
    sessionLabel::String
    variableLabel::String

    variable::Any # TODO SolverDataVariableFieldInput
end

StructTypes.omitempties(::Type{SolverDataCreateInput}) = (:variable,)

Base.@kwdef struct BlobEntryCreateInput
    blobId::UUID
    originId::UUID
    label::Symbol
    description::String
    hash::String
    mimeType::String
    blobstore::Symbol
    origin::String
    metadata::String
    _type::String
    _version::String
    timestamp::ZonedDateTime

    userLabel::String
    robotLabel::String = ""
    sessionLabel::String = ""
    variableLabel::String = ""
    factorLabel::String = ""

    user::Any = nothing# BlobEntryUserFieldInput
    robot::Any = nothing# BlobEntryRobotFieldInput
    session::Any = nothing# BlobEntrySessionFieldInput
    variable::Any = nothing# BlobEntryVariableFieldInput
    factor::Any = nothing# BlobEntryFactorFieldInput
end

function StructTypes.omitempties(::Type{BlobEntryCreateInput})
    return (:blobId, :user, :robot, :session, :variable, :factor)
end

# Variables
# Used by create and update
struct VariableResponse
    variables::Vector{Variable}
end

# VariableNodeData
# Used by create and update
struct SolverDataResponse
    solverData::Vector{PackedVariableNodeData}
end

## PPEs
# Used by create and update
struct PPEResponse
    ppes::Vector{MeanMaxPPE}
end

## DataEntries
# Used by create and update
struct BlobEntryResponse
    blobEntries::Vector{BlobEntry}
end
