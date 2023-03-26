# this is the GenericFunctionNodeData for packed types
const FactorData = DFG.PackedFunctionNodeData{InferenceType}

# Packed Factor

#TODO type not in DFG PackedFactor, should it be?
# _type::String 

Base.@kwdef struct FactorCreateInput
    label::Symbol #
    tags::Vector{Symbol} #
    _variableOrderSymbols::Vector{Symbol}
    timestamp::ZonedDateTime
    nstime::String = ""
    fnctype::String #
    solvable::Int
    data::String #
    metadata::String
    _type::String = "PackedFactor"
    _version::String #

    userLabel::String
    robotLabel::String
    sessionLabel::String
    
    variables::Any # TODO FactorVariablesFieldInput
    blobEntries::Any = nothing # TODO FactorBlobEntriesFieldInput
    session::Any # TODO FactorSessionFieldInput
end

StructTypes.omitempties(::Type{FactorCreateInput}) = (:blobEntries,)

# Factors
# Used by create and update
struct FactorResponse
    factors::Vector{PackedFactor}
end
