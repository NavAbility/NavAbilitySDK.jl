"""
addVariable!
Add a variable to the NavAbility Platform service
Example

```julia
addVariable!(fgclient, "x0", NvaSDK.Pose2)
```
"""
function DFG.addVariable!(
    fgclient::NavAbilityDFG,
    label::Union{<:AbstractString, Symbol},
    variableType::Union{<:AbstractString, Symbol, Type{<:VariableType}};
    tags::Vector{Symbol} = Symbol[],
    timestamp::ZonedDateTime = now(localzone()),
    solvable::Int = 1,
    nanosecondtime::Int64 = 0,
    smalldata::Dict{Symbol, DFG.SmallDataTypes} = Dict{Symbol, DFG.SmallDataTypes}(),
)
    union!(tags, [:VARIABLE])

    pacvar = VariableDFG(;
        id = nothing,
        label = Symbol(label),
        variableType = string(variableType),
        nstime = string(nanosecondtime),
        solvable,
        tags,
        metadata = base64encode(JSON3.write(smalldata)),
        timestamp,
    )

    return addVariable!(fgclient, pacvar)
end

# NOTE old addVariable::Event will be addVariableEvent
# function addVariableEvent end
# function addVariableAsync end

function DFG.addFactor!(
    fgclient::NavAbilityDFG,
    variables::Vector{String},
    fnc::InferenceType;
    kwargs...,
)
    return addFactor!(fgclient, Symbol.(variables), fnc; kwargs...)
end

function DFG.addFactor!(
    fgclient::NavAbilityDFG,
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
    factor = FactorDFG(;
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

    # add factor
    resultId = addFactor!(fgclient, factor)

    return resultId
end
