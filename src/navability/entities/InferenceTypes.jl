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
Base.@kwdef struct ZInferenceType <: InferenceType
  Z::Distribution
end

"""
$(TYPEDEF)
Pose2Point2BearingRangeInferenceType is used to represent a bearing
+ range measurement.
"""
Base.@kwdef struct Pose2Point2BearingRangeInferenceType <: InferenceType
  bearstr::Distribution
  rangstr::Distribution
end

"""
$(TYPEDEF)
InferenceType for Pose2AprilTag4CornersData.
"""
Base.@kwdef struct Pose2AprilTag4CornersInferenceType <: InferenceType
  corners::Vector{Float64}
  homography::Vector{Float64}
  K::Vector{Float64}
  taglength::Float64
  id::Int
  _type::String = "/application/JuliaLang/PackedPose2AprilTag4Corners"
end


Base.@kwdef struct ScatterAlignPose2InferenceType <: InferenceType
  """ This SDK only supports MKD clouds at this time. Note CJL also supports HeatmapGridDensity, TODO """
  cloud1::ManifoldKernelDensity
  cloud2::ManifoldKernelDensity
  """ Common grid scale for both images -- i.e. units/pixel.  
  Constructor uses two arguments `gridlength`*`rescale=1`=`gridscale`.
  Arg 0 < `rescale` ≤ 1 is also used to rescale the images to lower resolution for speed. """
  gridscale::Float64       = 1.0
  """ how many heatmap sampled particles to use for mmd alignment """
  sample_count::Int        = 50
  """ bandwidth to use for mmd """
  bw::Float64              = 0.01
  """ EXPERIMENTAL, flag whether to use 'stashing' for large point cloud, see CJL Docs Stash & Cache """
  useStashing::Bool        = false
  """ DataEntry ID for stash store of cloud 1 & 2 """
  dataEntry_cloud1::String = ""
  dataEntry_cloud2::String = ""
  """ Data store hint where likely to find the data entries and blobs for reconstructing cloud1 and cloud2"""
  dataStoreHint::String    = ""
  """ Convention store type within the object """
  _type::String            = "Caesar.PackedScatterAlignPose2"
end

"""
$(TYPEDEF)
InferenceType for MixtureData.
"""
Base.@kwdef struct MixtureInferenceType <: InferenceType
  N::Integer
  F_::String
  S::Vector{String}
  components::Vector{Distribution}
  diversity::Categorical
end
