## Wrap to standard API spec

# Leaving as comment for future plans, see https://github.com/NavAbility/nva-sdk/issues/21
# TODO What to use:
# - NavAbilityPlatform
# - NavAbilityConnection
# - NavAbilityClientContext
# - 
# mutable struct NavAbilityPlatform{T}
#     client
#     context::T
# end

# function NavAbilityPlatform(;
#             apiUrl::AbstractString="https://api.navability.io",
#             UserId::AbstractString="guest@navability.io",
#             RobotId::AbstractString=ENV["USER"],
#             SessionId::AbstractString="Session_" * string(uuid4())[1:8])
#     #
#     client = NavAbilityHttpsClient(apiUrl)
#     context = Client(UserId, RobotId, SessionId)
#     return NavAbilityPlatform(client, context)
# end

"""
  addVariable
Add a variable to the NavAbility Platform service
Example
```julia
addVariable(client, context, "x0", NVA.Pose2)
```
"""
function addVariable(client,
                     context,
                     label::Union{<:AbstractString,Symbol},
                     varType::Union{<:AbstractString,Symbol};
                     tags::Vector{String}=String[],
                     timestamp::String = string(now(Dates.UTC))*"Z")
                    # TODO
                    # solvable::Int=1
                    # nanosecondtime,
                    # smalldata,
    #
    union!(tags, ["VARIABLE"])
    v = Variable(string(label), Symbol(varType), tags, timestamp)
    return addVariable(client, context, v)
end


function assembleFactorName(xisyms::Union{Vector{String},Vector{Symbol}})
    return string(xisyms...,"f_",string(uuid4())[1:4])
end

function getFncTypeName(fnc::InferenceType)
    return split(string(typeof(fnc)),".")[end]
end
  

#TODO solverParams

function addFactor(client,
                   context,
                   xisyms::Union{Vector{String},Vector{Symbol}},
                   fnc::InferenceType;
                   multihypo::Vector{Float64}=Float64[],
                   nullhypo::Float64=0.0,
                   solvable::Int=1,
                   tags::Vector{String}=String[],
                   # timestamp::Union{DateTime,ZonedDateTime}=now(localzone()), #TODO why timestamp difference from IIF 
                   timestamp::String = string(now(Dates.UTC))*"Z",
                   inflation::Real=3.0,
                   namestring::String = assembleFactorName(xisyms),
                   nstime::String="0"
                  )
                   # TODO maybe                 
                   #  graphinit::Bool=true,
                   #  threadmodel=SingleThreaded,
                   #  suppressChecks::Bool=false,
                   #  _blockRecursion::Bool=!getSolverParams(dfg).attemptGradients
    #
    # create factor data
    factordata = FactorData(;fnc, multihypo, nullhypo, inflation)

    fncType = getFncTypeName(fnc)

    union!(tags, ["FACTOR"])
    # create factor 
    factor = Factor(
        namestring,
        nstime,
        fncType,
        string.(xisyms),
        factordata,
        solvable,
        tags,
        timestamp,
        DFG_VERSION
    )
    # add factor
    resultId = addFactor(client, context, factor)

    return resultId
end
