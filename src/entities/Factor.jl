
Base.@kwdef struct FactorCreateInput
    id::UUID#!
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

    variables::Any # TODO FactorVariablesFieldInput
    blobEntries::Any = nothing # TODO FactorBlobEntriesFieldInput
    fg::Any # TODO FactorFactorgraphFieldInput
end

StructTypes.omitempties(::Type{FactorCreateInput}) = (:blobEntries,)

# Factors
# Used by create and update
struct FactorResponse
    factors::Vector{PackedFactor}
end
#FIXME use named tuple
# FactorResponse = @NamedTuple{factors::Vector{PackedFactor}}