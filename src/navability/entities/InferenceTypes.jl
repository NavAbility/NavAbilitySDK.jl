# TODO: Refactor this to be full Inference Types and not just a serialization
# structure. It should look the same as Python SDK.

"""
$(TYPEDEF)
Abstract parent type for all InferenceTypes, which are the
functions inside of factors.
"""
abstract type InferenceType end

"""
$(TYPEDEF)
ZInferenceType is used by many factors as a common inference
type that uses a single distribution to express a constraint
between variables.
Used by: Prior, LinearRelative, PriorPose2, PriorPoint2, Pose2Pose2,
Point2Point2Range, etc.
"""
Base.@kwdef mutable struct ZInferenceType <: InferenceType
  Z::Distribution
end

"""
$(TYPEDEF)
InferenceType for Pose2AprilTag4Corners.
"""
Base.@kwdef struct Pose2AprilTag4CornersInferenceType <: InferenceType
  corners::Vector{Float64}
  homography::Vector{Float64}
  K::Vector{Float64}
  taglength::Float64
  id::Int
  _type::String = "/application/JuliaLang/PackedPose2AprilTag4Corners"
end