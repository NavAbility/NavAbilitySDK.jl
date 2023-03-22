"""
addVariable
Add a variable to the NavAbility Platform service
Example

```julia
addVariable!(fgclient, "x0", NvaSDK.Pose2)
```
"""
function addVariable!(
    fgclient::DFGClient,
    label::Union{<:AbstractString, Symbol},
    variableType::Union{<:AbstractString, Symbol};
    tags::Vector{Symbol} = Symbol[],
    timestamp::ZonedDateTime = now(localzone()),
    solvable::Int = 1,
    nstime::Int64 = 0,
    smalldata::Dict{Symbol, DFG.SmallDataTypes} = Dict{Symbol, DFG.SmallDataTypes}(),
    id = nothing,
)
    union!(tags, [:VARIABLE])

    pacvar = PackedVariable(;
        id,
        label = Symbol(label),
        variableType = string(variableType),
        nstime,
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

function assembleFactorName(xisyms::Union{Vector{String}, Vector{Symbol}})
    return Symbol(xisyms..., "f_", string(uuid4())[1:4])
end

getFncTypeName(fnc::InferenceType) = split(string(typeof(fnc)), ".")[end]

function addFactor!(
    fgclient::DFGClient,
    variables::Vector{String},
    fnc::InferenceType;
    kwargs...,
)
    return addFactor!(fgclient, Symbol.(variables), fnc; kwargs...)
end

function addFactor!(
    fgclient::DFGClient,
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
        nstime,
        fnctype,
        solvable,
        data = base64encode(JSON3.write(factordata)),
        metadata = base64encode(JSON3.write(metadata)),
    )

    # add factor
    resultId = addFactor!(fgclient, factor)

    return resultId
end
