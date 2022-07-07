
"""
$(TYPEDEF)
Solver options including the solve key and whether the
parametric solver should be used.
"""
Base.@kwdef struct SolveOptions
    key::Union{String, Nothing}
    useParametric::Bool = false
end

