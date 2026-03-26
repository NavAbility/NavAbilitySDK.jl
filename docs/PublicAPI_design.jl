### Public API - supported in all SDKs

# All funcitons should follow DistributedFactorGraphs.jl and we use Julia here to define the signitures.

# Other lanuages should follow DFG.jl/NvaSDK.jl as closely as possible with the following exceptions
# - labels are Symbols in julia and strings elsewhere.
# - mutation in julia is done with ! at the end of the function name and not in other languages.
# - notably C and Rust do not support function overloading and may also be different or more explicit and perhaps using adjectives.

## Structs

## Functions

### Singular `get` 

getVariable(dfg::NavAbilityDFG, label::Symbol)

getFactor(dfg::NavAbilityDFG, label::Symbol)

getBlobentry(dfg::NavAbilityDFG, variableLabel::Symbol, label::Symbol)

getVariableBlobentry(dfg::NavAbilityDFG, variableLabel::Symbol, label::Symbol)

getFactorBlobentry(dfg::NavAbilityDFG, factorLabel::Symbol, label::Symbol)

getGraphBlobentry(dfg::NavAbilityDFG, label::Symbol)

getAgentBlobentry(dfg::NavAbilityDFG, label::Symbol)

getState(dfg::NavAbilityDFG, variableLabel::Symbol, label::Symbol)

getBlob(store::NavAbilityBlobstore, blobId::UUID)

### Plural `get` 
getVariables(
    dfg::NavAbilityDFG,
    labels::Vector{Symbol}
)
getVariables(
    dfg::NavAbilityDFG;
    solvableFilter::Union{Nothing, Function} = nothing,
    labelFilter::Union{Nothing, Function} = nothing,
    tagsFilter::Union{Nothing, Function} = nothing,
    typeFilter::Union{Nothing, Function} = nothing,
)

getFactors(
    dfg::NavAbilityDFG,
    labels::Vector{Symbol}
)
getFactors(
    dfg::NavAbilityDFG;
    solvableFilter::Union{Nothing, Function} = nothing,
    labelFilter::Union{Nothing, Function} = nothing,
    tagsFilter::Union{Nothing, Function} = nothing,
    typeFilter::Union{Nothing, Function} = nothing,
)

### Singular `add`

addVariable!(dfg::NavAbilityDFG, variable::AbstractGraphVariable)

addFactor!(dfg::NavAbilityDFG, factor::AbstractGraphFactor)

addBlobentry!(dfg::NavAbilityDFG, variableLabel::Symbol, entry::Blobentry)

addGraphBlobentry!(dfg::NavAbilityDFG, entry::Blobentry)

addAgentBlobentry!(dfg::NavAbilityDFG, entry::Blobentry)

addBlob!(store::NavAbilityBlobstore, blobId::UUID, blob::Vector{UInt8})

### Plural `add` 

addVariables!(dfg::NavAbilityDFG, variables::Vector{<:AbstractGraphVariable})

addFactors!(dfg::NavAbilityDFG, factors::Vector{<:AbstractGraphFactor})

addBlobentries!(dfg::NavAbilityDFG, variableLabel::Symbol, entries::Vector{Blobentry})

addGraphBlobentries!(dfg::NavAbilityDFG, entries::Vector{Blobentry})

addAgentBlobentries!(dfg::NavAbilityDFG, entries::Vector{Blobentry})

### Singular `update` 

### Plural `update` 

### Singular `delete` 

### Plural `delete` 

### `list`