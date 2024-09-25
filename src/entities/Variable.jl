Base.@kwdef struct VariableCreateInput
    id::UUID
    label::String
    nstime::String = ""
    variableType::String
    solvable::Int64 = 1
    tags::Vector{String} = ["VARIABLE"]
    metadata::String = "e30="
    _version::String = string(DFG._getDFGVersion())
    timestamp::String = string(now(localzone()))

    ppes::Any = nothing #TODO VariablePpesFieldInput
    blobEntries::Any = nothing #TODO VariableBlobEntriesFieldInput
    solverData::Any = nothing #TODO VariableSolverDataFieldInput
    factors::Any = nothing #TODO VariableFactorsFieldInput
    fg::Any #TODO VariableFactorGraphFieldInput
end

function StructTypes.omitempties(::Type{VariableCreateInput})
    return (:ppes, :blobEntries, :solverData, :factors)
end

Base.@kwdef struct PPECreateInput
    id::UUID
    solveKey::Symbol
    suggested::Vector{Float64}
    max::Vector{Float64}
    mean::Vector{Float64}
    _type::String = "MeanMaxPPE"
    _version::String = string(DFG._getDFGVersion())

    # suggested_cartesian::Any = nothing #TODO PointInput
    # max_cartesian::Any = nothing #TODO PointInput
    # mean_cartesian::Any = nothing #TODO PointInput
    variable::Any  #TODO PPEVariableFieldInput
end

function StructTypes.omitempties(::Type{PPECreateInput})
    # return (:suggested_cartesian, :max_cartesian, :mean_cartesian, :variable)
    return (:variable, )
end

Base.@kwdef struct SolverDataCreateInput
    id::UUID
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

    variable::Any # TODO SolverDataVariableFieldInput
end

StructTypes.omitempties(::Type{SolverDataCreateInput}) = (:variable,)

Base.@kwdef struct BlobEntryCreateInput
    id::UUID
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
    size::Int

    # userLabel::String
    # robotLabel::String = ""
    # sessionLabel::String = ""
    # variableLabel::String = ""
    # factorLabel::String = ""

    parent::Any = nothing# BlobEntryParentFieldInput
end

function StructTypes.omitempties(::Type{BlobEntryCreateInput})
    return (:blobId, :user, :robot, :session, :variable, :factor)
end

# Variables
# Used by create and update
#FIXME use named tuple
struct VariableResponse
    variables::Vector{Variable}
end
# VariableResponse = @NamedTuple{variables::Vector{Variable}}

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
