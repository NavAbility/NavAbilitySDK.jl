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
    multihypo::Vector{Int} = []
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
Create a prior for a Pose2 factor with a distribution Z representing (x,y,theta) prior information, 
    e.g. `FullNormal([0.0, 0.0, 0.0], diagm([0.01, 0.01, 0.01]))`.

Default value of Z = `FullNormal([0.0, 0.0, 0.0], diagm([0.01, 0.01, 0.01]))`.
"""
function PriorPose2Data(;Z::Distribution = FullNormal([0.0, 0.0, 0.0], diagm([0.01, 0.01, 0.01])))::FactorData
    data = FactorData(fnc = ZInferenceType(Z), certainhypo = [1])
    return data
end

"""
$(SIGNATURES)
Create a Pose2->Pose2 factor with a distribution Z representing the (x,y,theta) relationship
between the variables, e.g. `FullNormal([1,0,0.3333*π], diagm([0.01,0.01,0.01]))`.

Default value of Z = `FullNormal([1,0,0.3333*π], diagm([0.01,0.01,0.01]))`.
"""
function Pose2Pose2Data(;Z::Distribution = FullNormal([1,0,0.3333*π], diagm([0.01, 0.01, 0.01])))::FactorData
    data = FactorData(fnc = ZInferenceType(Z), certainhypo = [1, 2])
    return data
end

"""
$(SIGNATURES)
Create a Pose2->Point2 bearing+range factor with distributions:
- bearing: The bearing from the pose to the point, default `Normal(0, 1)`.
- range: The range from the pose to the point, default `Normal(1, 1)`.
"""
function Pose2Point2BearingRange(;bearing::Distribution = Normal(0, 1), range::Distribution = Normal(1, 1))::FactorData
    data = FactorData(fnc = Pose2Point2BearingRangeInferenceType(bearing, range), certainhypo = [1, 2])
    return data
end


"""
$(SIGNATURES)
Create a AprilTags factor that directly relates a Pose2 to the information from an AprilTag reading.
Corners need to be provided, homography and tag length are defaulted and can be overwritten.
"""
function Pose2AprilTag4CornersData(id, corners::Vector{Float64}, homography::Vector{Float64}; K::Vector{Float64}=[300.0,0.0,0.0,0.0,300.0,0.0,180.0,120.0,1.0], taglength::Float64=0.25)::FactorData
    fnc = Pose2AprilTag4CornersInferenceType(
        corners=corners,
        homography=homography,
        K=K,
        taglength=taglength,
        id=id
    )
    data = FactorData(fnc = fnc, certainhypo = [1, 2])
    return data
end



function Factor(label::String, fncType::String, variableOrderSymbols::Vector{String}, data::FactorData; tags::Vector{String}=["FACTOR"], timestamp::String = string(now(Dates.UTC))*"Z")::Factor
    # TODO: Remove independent updates of this and set certainhypo here.
    data.certainhypo = Vector{Int}(1:size(variableOrderSymbols)[1])
    
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

