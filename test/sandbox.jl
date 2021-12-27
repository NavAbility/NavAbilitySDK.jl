using DistributedFactorGraphs
using NavAbilitySDK

# Login if no token is provided.
token = "eyJraWQiOiJ4cm45emxTSTZLVkF2NmpRanNuZHVwZ3ZMbXdqNm9nOWpWc09sT2hjbE9NPSIsImFsZyI6IlJTMjU2In0.eyJhdF9oYXNoIjoiblpSbjlKQW5jNXd6QlRXc09HWnlOUSIsInN1YiI6IjIxNTMwYTJlLTU2NzAtNDIzMS1hZWVhLTkxNjgwMzA4NmRhMSIsImVtYWlsX3ZlcmlmaWVkIjp0cnVlLCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0yLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMl9hbkVXSWVWa0IiLCJwaG9uZV9udW1iZXJfdmVyaWZpZWQiOnRydWUsImNvZ25pdG86dXNlcm5hbWUiOiJUZXN0VXNlciIsImF1ZCI6ImRoNGZpYzZiM2ZmaWVrOXNnNWkxMTdxbWUiLCJldmVudF9pZCI6IjhmZTQ5MTQ2LWRhZmQtNGM3Ni05OTJkLWM3YmY2ZTE2MjkzZCIsInRva2VuX3VzZSI6ImlkIiwiYXV0aF90aW1lIjoxNjI3MzQxNzIwLCJwaG9uZV9udW1iZXIiOiIrMTYzMDY5OTkwMzkiLCJleHAiOjE2Mjc0MjgxMjAsImlhdCI6MTYyNzM0MTcyMCwiZW1haWwiOiJzYW1AZ2xvYnVzLm9yZyJ9.g9Rqybo4eXlB6U5-5DKlouYyv0eOYhSUnPZRK7p5G812cigZGF6lItSqWUBxrdZkB0rkBH10dJIghiJVx60XM2LSxAUVcVlwoA_lpMyatafDjqdfpsivj6hsfswmiszSmbURMIjbTi958yxyPhgpn-4W6kQr_Pja-oikc0P_VUO4kc5PAFNd5bNVAvqNw9gcqcBt-rPgy70kPtND3a-zJeU150c9DE4Pf6DR50Ed5oSdVKpN_m0AqrXcZSd3cg1cqj6df6u-0qYmGVUAL0aXOKJ1vhNuZ--5iLlX3MI_KwCmFfllD_1VBNx1RFyWNZFhpSxEDvK5D7p9GocE5B2UxA"
cfg = CloudDFG(token=token)
# cfg = CloudDFG(token=token)
cfg.sessionId = "Session_c862e5"

variables = listVariables(cfg)
# Filtering: "x.*"
variables = listVariables(cfg, r"x.*"; solvable=1)

factors = listFactors(cfg)
variables = listFactors(cfg, r"x0.*")


# SANDBOX
import NavAbilitySDK: _gqlClient, query
# import DistributedFactorGraphs: listVariables

gql_getVariable(label::String) = """
    query getVariable(\$userId: ID!, \$robotId: ID!, \$sessionId: ID!) {
      VARIABLE(filter: {
            label: "$label",
            session: {
              id: \$sessionId, 
              robot: {
                id: \$robotId, 
                  user: {
                  id: \$userId
              }}}
            }) 
      {
        label
        timestamp {formatted}
        variableType
        smallData
        solvable
        tags
        _version
        _id
        ppes {
          solveKey
          suggested
          max
          mean
          _type
          _version
          lastUpdatedTimestamp {formatted}
        }
        solverData 
        {
          solveKey
          BayesNetOutVertIDs
          BayesNetVertID
          dimIDs
          dimbw
          dims
          dimval
          dontmargin
          eliminated
          infoPerCoord
          initialized
          ismargin
          separator
          solveInProgress
          solvedCount
          variableType
          vecbw
          vecval
          _version
        }
      }
    }
"""

function getVariable(dfg::CloudDFG, 
  label::Union{Symbol, String})
  #
  client = _gqlClient(dfg.userId, dfg.robotId, dfg.sessionId)
  q = gql_getVariable(String(label))
  @debug "DEBUG: Query = \r\n$q"
  result = query(dfg.client, q, "getVariable", client)["VARIABLE"]
  @show result
  # return Symbol.(sort([v["label"] for v in result["VARIABLE"]]))
end

getVariable(cfg, :x0)


function listVariables(dfg::CloudDFG, 
  regexFilter::Union{Nothing, Regex}=nothing; 
  tags::Vector{Symbol}=Symbol[], 
  solvable::Int=0 )
#
  client = _gqlClient(dfg.userId, dfg.robotId, dfg.sessionId)
  q = gql_ls(regexFilter=regexFilter, tags=tags, solvable=solvable)
  @debug "DEBUG: Query = \r\n$q"
  result = query(dfg.client, q, "ls", client)
  return Symbol.(sort([v["label"] for v in result["VARIABLE"]]))
end


## shortcut to packed variable Julia, will do Python / JS after this works.
using IncrementalInference, RoME
# create temp in memory graph that we will tee up to server via cfg
lfg = initfg() # LightDFG
v0 = addVariable!(lfg, :x0, Pose2)
v1 = addVariable!(lfg, :x1, Pose2)
v2 = addVariable!(lfg, :x2, Pose2)
v3 = addVariable!(lfg, :l1, Pose2, tags=[:LANDMARK])

# We have v0, v1, and v2. Let's send it up the wire to the cloud...
result = addVariable!(cfg, v0)
result = addVariable!(cfg, v1)
result = addVariable!(cfg, v2)
result = addVariable!(cfg, v3)

@info "Adding to session: $(cfg.sessionId)"

## Prior factor
x0f1 = addFactor!(lfg, [:x0], PriorPose2( MvNormal([10; 10; pi/6.0], Matrix(Diagonal([0.1;0.1;0.05].^2))) ) ) 
result = addFactor!(cfg, x0f1)

## Pose2Pose2 factors
pp = Pose2Pose2(MvNormal([10.0;0;pi/3], Matrix(Diagonal([0.1;0.1;0.1].^2))))
x0x1f1 = addFactor!(lfg, [:x0; :x1], pp)
x1x2f1 = addFactor!(lfg, [:x1; :x2], deepcopy(pp))
result = addFactor!(cfg, x0x1f1)
result = addFactor!(cfg, x1x2f1)

## Th. th. th... that's all folks! 
# Will include more on how to pull/query data and how to query the status of your uploaded data!
