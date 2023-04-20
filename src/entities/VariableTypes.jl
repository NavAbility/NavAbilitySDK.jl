abstract type VariableType end

macro defSDKVariable(modulename, structname)
    return esc(quote
        Base.@__doc__ struct $structname <: VariableType end
        Base.string(::Type{$structname}) = $modulename*"."*string(nameof($structname))
    end)
end


"""
$(TYPEDEF)
General 1 dimensional variable.
"""
@defSDKVariable "IncrementalInference" ContinuousScalar

"""
$(TYPEDEF)
XY Euclidean manifold variable.
"""
@defSDKVariable "RoME" Point2

"""
$(TYPEDEF)
XYZ Euclidean manifold variable..
"""
@defSDKVariable "RoME" Point3

"""
$(TYPEDEF)
SpecialEuclidean(2) manifold, two Euclidean translations and one Circular rotation, used for general 2D SLAM.
"""
@defSDKVariable "RoME" Pose2

"""
$(TYPEDEF)
SpecialEuclidean(3) manifold used for 3D SLAM.
"""
@defSDKVariable "RoME" Pose3
