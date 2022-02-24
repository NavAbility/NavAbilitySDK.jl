using Dates

DFG_VERSION = "0.18.1";

@enum FactorType begin
    PRIORPOSE2
    POSE2POSE2
    POSE2APRILTAG4CORNERS
end

mutable struct FactorData
    eliminated::Bool
    potentialused::Bool
    edgeIDs::Vector{String}
    fnc::Dict{String,Any}
    multihypo::Vector{Int}
    certainhypo::Vector{Int}
    nullhypo::Float64
    solveInProgress::Int
    inflation::Float64
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

function InitializeFactorData()::FactorData
    return FactorData(
        false,
        false,
        [],
        Dict{String,Any}(),
        [],
        [],
        0.0,
        0,
        3.0
    )
end

function PriorPose2Data(;xythetaPrior = [0.0, 0.0, 0.0], xythetaCovars = [0.01, 0.01, 0.01])::FactorData
    fnc = Dict(
        "Z" => Dict(
            "_type" => "IncrementalInference.PackedFullNormal",
            "mu" => xythetaPrior,
            "cov" => [xythetaCovars[1], 0.0, 0.0, 0.0, xythetaCovars[2], 0.0, 0.0, 0.0, xythetaCovars[3]],
        )
    )
    data = InitializeFactorData()
    data.fnc = fnc
    data.certainhypo = [1]
    return data
end

function Pose2Pose2Data(;mus=[1,0,0.3333*π], sigmas=[0.01,0.01,0.01])::FactorData
    fnc = Dict(
        "Z" => Dict(
            "_type" => "IncrementalInference.PackedFullNormal",
            "mu" => mus,
            "cov" => [sigmas[1], 0.0, 0.0, 0.0, sigmas[2], 0.0, 0.0, 0.0, sigmas[3]],
        )
    )
    data = InitializeFactorData()
    data.fnc = fnc
    data.certainhypo = [1, 2]
    return data
end

function Pose2AprilTag4CornersData(id, corners, homography; K=[300.0,0.0,0.0,0.0,300.0,0.0,180.0,120.0,1.0], taglength=0.25)::FactorData
    fnc = Dict{String,Any}(
        "_type" => "/application/JuliaLang/PackedPose2AprilTag4Corners",
        "corners" => corners,
        "homography" => homography,
        "K" => K,
        "taglength" => taglength,
        "id" => id
    )
    data = InitializeFactorData()
    data.fnc = fnc
    data.certainhypo = [1, 2]
    return data
end

function Factor(label::String, fncType::String, variableOrderSymbols::Vector{String}, data::FactorData; tags::Vector{String}=["FACTOR"], timestamp::String = string(now(Dates.UTC))*"Z")::Factor
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

