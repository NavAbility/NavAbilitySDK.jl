
"""
$(TYPEDEF)
Abstract parent type for all distributions.
"""
abstract type Distribution end

"""
$(TYPEDEF)
One dimensional normal distribution.
"""
Base.@kwdef mutable struct Normal <: Distribution
  mu::Float64
  sigma::Float64
  _type::String = "IncrementalInference.PackedNormal"
end
Normal(mu::Number, sigma::Number) = Normal(mu=mu, sigma=sigma)

"""
$(TYPEDEF)
One dimensional Rayleigh distribution.
"""
Base.@kwdef mutable struct Rayleigh <: Distribution
  sigma::Float64
  _type::String = "IncrementalInference.PackedRayleigh"
end
Rayleigh(sigma::Number) = Rayleigh(sigma=sigma)

"""
$(TYPEDEF)
Multidimensional normal distribution specified by means and a covariance matrix.
"""
Base.@kwdef mutable struct FullNormal <: Distribution
  mu::Vector{Float64}
  cov::Vector{Float64}
  _type::String = "IncrementalInference.PackedFullNormal"
end
# TODO: Generalize this to any number type.
FullNormal(mu::Vector{Float64}, cov::Matrix{Float64}) = FullNormal(mu=mu, cov=vec(cov))

"""
$(TYPEDEF)
One dimensional uniform distribution.
"""
Base.@kwdef mutable struct Uniform <: Distribution
  a::Float64
  b::Float64
  _type::String = "IncrementalInference.PackedUniform"
end
Uniform(a::Number, b::Number) = Uniform(a=a, b=b)

"""
$(TYPEDEF)
Categorical distribution specified by a set of probabilities summing up to 1.
"""
Base.@kwdef mutable struct Categorical <: Distribution
  p::Vector{Float64}
  _type::String = "IncrementalInference.PackedCategorical"
end
# TODO: Generalize this to any number type.
Categorical(p::Vector{Float64}) = Categorical(p=p)