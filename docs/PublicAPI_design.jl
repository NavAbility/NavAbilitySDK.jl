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

getVariableState(dfg::NavAbilityDFG, variableLabel::Symbol, label::Symbol)

getFactorState(dfg::NavAbilityDFG, factorLabel::Symbol)

getBlob(store::NavAbilityBlobstore, blobId::UUID)

### Plural `get` 

### Singular `add` 

addBlob!(store::NavAbilityBlobstore, blobId::UUID, blob::Vector{UInt8})


### Plural `add` 

### Singular `update` 

### Plural `update` 

### Singular `delete` 

### Plural `delete` 

### `list`