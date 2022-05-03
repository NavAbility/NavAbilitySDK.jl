using Dates

DFG_VERSION = "0.18.1";

@enum FactorType begin
    PRIORPOSE2
    POSE2POSE2
    POSE2APRILTAG4CORNERS
end

Base.@kwdef mutable struct FactorData
    eliminated::Bool = false
    potentialused::Bool = false
    edgeIDs::Vector{String} = []
    fnc::InferenceType
    multihypo::Vector{Float64} = []
    certainhypo::Vector{Int} = []
    nullhypo::Float64 = 0.0
    solveInProgress::Int = 0
    inflation::Float64 = 3.0
end

struct Factor
    label::String
    nstime::String
    fnctype::String
    _variableOrderSymbols::Vector{String}
    data::FactorData
    solvable::Int
    tags::Vector{String}
    timestamp::String
    _version::String
end


"""
$(SIGNATURES)
Create a prior factor for a ContinuousScalar (a.k.a. Pose1) with a distribution Z representing 1D prior information, 
    e.g. `Normal(0.0, 0.1)`.

Default value of Z = `Normal(0.0, 0.1)`.
"""
function PriorData(;Z::Distribution = Normal(0.0, 0.1), kwargs...)::FactorData
    data = FactorData(;fnc = ZInferenceType(Z), certainhypo = [1], kwargs...)
    return data
end

"""
$(SIGNATURES)
Create a prior factor for a Pose2 with a distribution Z representing (x,y,theta) prior information, 
    e.g. `FullNormal([0.0, 0.0, 0.0], diagm([0.01, 0.01, 0.01]))`.

Default value of Z = `FullNormal([0.0, 0.0, 0.0], diagm([0.01, 0.01, 0.01]))`.
"""
function PriorPose2Data(;Z::Distribution = FullNormal([0.0, 0.0, 0.0], diagm([0.01, 0.01, 0.01])), kwargs...)::FactorData
    data = FactorData(;fnc = ZInferenceType(Z), certainhypo = [1], kwargs...)
    return data
end

"""
$(SIGNATURES)
Create a prior factor for a Point2 with a distribution Z representing (x,y) prior information, 
    e.g. `FullNormal([0.0, 0.0.0], diagm([0.01, 0.01]))`.

Default value of Z = `FullNormal([0.0, 0.0], diagm([0.01, 0.01]))`.
"""
function PriorPoint2Data(;Z::Distribution = FullNormal([0.0, 0.0], diagm([0.01, 0.01])), kwargs...)::FactorData
    data = FactorData(;fnc = ZInferenceType(Z), certainhypo = [1], kwargs...)
    return data
end

"""
$(SIGNATURES)
Create a ContinousScalar->ContinousScalar (also known as Pose1->Pose1) factor with a distribution Z representing the 1D relationship
between the variables, e.g. `Normal(1.0, 0.1)`.

Default value of Z = `Normal(1.0, 0.1)`.
"""
function LinearRelativeData(;Z::Distribution = Normal(1.0, 0.1), kwargs...)::FactorData
    data = FactorData(;fnc = ZInferenceType(Z), certainhypo = [1, 2], kwargs...)
    return data
end

"""
$(SIGNATURES)
Create a Pose2->Pose2 factor with a distribution Z representing the (x,y,theta) relationship
between the variables, e.g. `FullNormal([1,0,0.3333*π], diagm([0.01,0.01,0.01]))`.

Default value of Z = `FullNormal([1,0,0.3333*π], diagm([0.01,0.01,0.01]))`.
"""
function Pose2Pose2Data(;Z::Distribution = FullNormal([1,0,0.3333*π], diagm([0.01, 0.01, 0.01])), kwargs...)::FactorData
    data = FactorData(;fnc = ZInferenceType(Z), certainhypo = [1, 2], kwargs...)
    return data
end

"""
$(SIGNATURES)
Create a Pose2->Point2 bearing+range factor with 1D distributions:
- bearing: The bearing from the pose to the point, default `Normal(0, 1)`.
- range: The range from the pose to the point, default `Normal(1, 1)`.
"""
function Pose2Point2BearingRangeData(;bearing::Distribution = Normal(0, 1), range::Distribution = Normal(1, 1), kwargs...)::FactorData
    data = FactorData(;fnc = Pose2Point2BearingRangeInferenceType(bearing, range), certainhypo = [1, 2], kwargs...)
    return data
end

"""
$(SIGNATURES)
Create a Point2->Point2 range factor with a 1D distribution:
- range: The range from the pose to the point, default `Normal(1, 1)`.
"""
function Point2Point2RangeData(;range::Distribution = Normal(1, 1), kwargs...)::FactorData
    data = FactorData(;fnc = ZInferenceType(range), certainhypo = [1, 2], kwargs...)
    return data
end

"""
$(SIGNATURES)
Create a AprilTags factor that directly relates a Pose2 to the information from an AprilTag reading.
Corners need to be provided, homography and tag length are defaulted and can be overwritten.
"""
function Pose2AprilTag4CornersData(id, corners::Vector{Float64}, homography::Vector{Float64}; K::Vector{Float64}=[300.0,0.0,0.0,0.0,300.0,0.0,180.0,120.0,1.0], taglength::Float64=0.25, kwargs...)::FactorData
    fnc = Pose2AprilTag4CornersInferenceType(;corners,homography,K,taglength,id)
    data = FactorData(; fnc, certainhypo = [1, 2], kwargs...)
    return data
end

"""
$(SIGNATURES)

Returns `<:FactorData`
"""
function ScatterAlignPose2Data(
        varType::AbstractString, 
        cloud1::AbstractVector{<:AbstractVector{<:Real}}, 
        cloud2::AbstractVector{<:AbstractVector{<:Real}},
        bw1::AbstractVector{<:Real}=Float64[],
        bw2::AbstractVector{<:Real}=Float64[];
        mkd1 = ManifoldKernelDensity(; varType, pts=cloud1, bw=bw1 ),
        mkd2 = ManifoldKernelDensity(; varType, pts=cloud2, bw=bw2 ),
        kw_sap::NamedTuple=(;),
        kwargs...
    )
    #
    
    fnc = ScatterAlignPose2InferenceType(; cloud1=mkd1, cloud2=mkd2, kw_sap...)
    data = FactorData(; fnc, certainhypo = [1, 2], kwargs...)
    return data
end

"""
$(SIGNATURES)
Create a Mixture factor type with an underlying factor type, a named set of
distributions that should be mixed, the probabilities of each distribution
(the mix), and the dimensions of the underlying factor (e.g.
ContinuousScalar=1, Pose2Pose2=3, etc.).

Args:
    mechanics (Type{FactorData}): The underlying factor data type, e.g. Pose2Pose2Data. NOTE: This will change in later versions 
    but for now it can be any of the FactorData classes (e,g, LinearRelative, not the object LinearRelative()).
    components (NamedTuple): The named tuple set of distributions that
    should be mixed, e.g. NamedTuple(hypo1=Normal(0, 2)), hypo2=Uniform(30, 55)).
    probabilities (List[float]): The probabilities of each distribution (the mix), e.g. [0.4, 0.6].
    dims (int): The dimensions of the underlying factor, e.g. for Pose2Pose2 it's 3.
"""
function MixtureData(
        # TODO: Need to make this type constrained to Type{<:InferenceType}
        mechanics, 
        # TODO: Need to made this something cleaner and more type stable, maybe OrderedDict
        components::NamedTuple,
        probabilities::Vector{Float64},
        dims::Integer  # TODO: Confirming we can remove.
        )::FactorData #where T<:FactorData
    data = FactorData(;
        fnc = MixtureInferenceType(
            N = length(components),
            # @jim-hill-r this is why I don't like the Data suffix.
            F_ = "Packed$(replace(string(mechanics), "Data" => ""))",
            S = collect(string.(keys(components))),
            components = collect(values(components)),
            diversity = Categorical(probabilities)
        ), certainhypo = [] # This should be updated in the Factor constructor below.
    )
    return data
end


function Factor(
        label::String, 
        fncType::String, 
        variableOrderSymbols::Vector{String}, 
        data::FactorData; 
        tags::Vector{String}=["FACTOR"], 
        timestamp::String = string(now(Dates.UTC))*"Z", 
        multihypo=nothing,
        nullhypo=nothing
    )::Factor
    #
    # TODO: Remove independent updates of this and set certainhypo here.
    data.certainhypo = Vector{Int}(1:size(variableOrderSymbols)[1])
    if multihypo !== nothing
        data.multihypo = multihypo
    end
    if nullhypo !== nothing
        data.nullhypo = float(nullhypo)
    end
    
    result = Factor(
        label,
        "0",
        fncType,
        variableOrderSymbols,
        data,
        1,
        tags,
        timestamp,
        DFG_VERSION
    )
    return result
end

