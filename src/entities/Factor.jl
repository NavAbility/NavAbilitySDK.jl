# this is the GenericFunctionNodeData for packed types
#TODO move to DFG?
const FactorData = DFG.PackedFunctionNodeData{InferenceType}

# Packed Factor constructor
function Factor(
    xisyms::Vector{Symbol},
    fnc::InferenceType;
    multihypo::Vector{Float64} = Float64[],
    nullhypo::Float64 = 0.0,
    solvable::Int = 1,
    tags::Vector{Symbol} = Symbol[],
    timestamp::ZonedDateTime = TimeZones.now(tz"UTC"),
    inflation::Real = 3.0,
    label::Symbol = assembleFactorName(xisyms),
    nstime::Int = 0,
    metadata::Dict{Symbol, DFG.SmallDataTypes} = Dict{Symbol, DFG.SmallDataTypes}(),
)
    # create factor data
    factordata = FactorData(; fnc, multihypo, nullhypo, inflation)

    fnctype = getFncTypeName(fnc)

    union!(tags, [:FACTOR])
    # create factor 
    factor = PackedFactor(;
        label,
        tags,
        _variableOrderSymbols = xisyms,
        timestamp,
        nstime = string(nstime),
        fnctype,
        solvable,
        data = base64encode(JSON3.write(factordata)),
        metadata = base64encode(JSON3.write(metadata)),
    )

    return factor
end
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
