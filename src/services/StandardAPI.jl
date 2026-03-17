
function DFG.addVariable!(
    dfg::NavAbilityDFG{VariableDFG},
    label::Symbol,
    ::Union{T, Type{T}}; # statekind
    kwargs...,
) where {T <: StateType}
    addVariable!(dfg, VariableDFG(label, T; kwargs...))
end

function DFG.addFactor!(
    dfg::NavAbilityDFG{VariableDFG, FactorDFG},
    variableorder::Vector{Symbol},
    observation::AbstractObservation;
    kwargs...,
)
    return addFactor!(dfg, FactorDFG(variableorder, observation; kwargs...))
end
