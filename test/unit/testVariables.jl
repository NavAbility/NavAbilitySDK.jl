@testset "Variable Tests" begin
  v = Variable("x0", :ContinuousScalar)
  # NOTE: A timestamp substitution is done in these JSON payloads.
  @test JSON.json(v) == "{\"label\":\"x0\",\"dataEntry\":\"{}\",\"nstime\":\"0\",\"variableType\":\"IncrementalInference.ContinuousScalar\",\"dataEntryType\":\"{}\",\"ppeDict\":\"{}\",\"solverDataDict\":\"{\\\"default\\\":{\\\"vecval\\\":[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],\\\"dimval\\\":1,\\\"vecbw\\\":[0.0],\\\"dimbw\\\":1,\\\"BayesNetOutVertIDs\\\":[],\\\"dimIDs\\\":[0],\\\"dims\\\":1,\\\"eliminated\\\":false,\\\"BayesNetVertID\\\":\\\"_null\\\",\\\"separator\\\":[],\\\"variableType\\\":\\\"IncrementalInference.ContinuousScalar\\\",\\\"initialized\\\":false,\\\"infoPerCoord\\\":[0.0],\\\"ismargin\\\":false,\\\"dontmargin\\\":false,\\\"solveInProgress\\\":0,\\\"solvedCount\\\":0,\\\"solveKey\\\":\\\"default\\\"}}\",\"smallData\":\"{}\",\"solvable\":1,\"tags\":\"[\\\"VARIABLE\\\"]\",\"timestamp\":$(JSON.json(v.timestamp)),\"_version\":\"0.18.1\"}"

  v = Variable("x0", :Pose1, ["TEST_TAG"])
  @test JSON.json(v) == "{\"label\":\"x0\",\"dataEntry\":\"{}\",\"nstime\":\"0\",\"variableType\":\"IncrementalInference.ContinuousScalar\",\"dataEntryType\":\"{}\",\"ppeDict\":\"{}\",\"solverDataDict\":\"{\\\"default\\\":{\\\"vecval\\\":[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],\\\"dimval\\\":1,\\\"vecbw\\\":[0.0],\\\"dimbw\\\":1,\\\"BayesNetOutVertIDs\\\":[],\\\"dimIDs\\\":[0],\\\"dims\\\":1,\\\"eliminated\\\":false,\\\"BayesNetVertID\\\":\\\"_null\\\",\\\"separator\\\":[],\\\"variableType\\\":\\\"IncrementalInference.ContinuousScalar\\\",\\\"initialized\\\":false,\\\"infoPerCoord\\\":[0.0],\\\"ismargin\\\":false,\\\"dontmargin\\\":false,\\\"solveInProgress\\\":0,\\\"solvedCount\\\":0,\\\"solveKey\\\":\\\"default\\\"}}\",\"smallData\":\"{}\",\"solvable\":1,\"tags\":\"[\\\"TEST_TAG\\\"]\",\"timestamp\":$(JSON.json(v.timestamp)),\"_version\":\"0.18.1\"}"

  v = Variable("x0", :Pose2)
  @test JSON.json(v) == "{\"label\":\"x0\",\"dataEntry\":\"{}\",\"nstime\":\"0\",\"variableType\":\"RoME.Pose2\",\"dataEntryType\":\"{}\",\"ppeDict\":\"{}\",\"solverDataDict\":\"{\\\"default\\\":{\\\"vecval\\\":[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],\\\"dimval\\\":3,\\\"vecbw\\\":[0.0,0.0,0.0],\\\"dimbw\\\":3,\\\"BayesNetOutVertIDs\\\":[],\\\"dimIDs\\\":[0,1,2],\\\"dims\\\":3,\\\"eliminated\\\":false,\\\"BayesNetVertID\\\":\\\"_null\\\",\\\"separator\\\":[],\\\"variableType\\\":\\\"RoME.Pose2\\\",\\\"initialized\\\":false,\\\"infoPerCoord\\\":[0.0,0.0,0.0],\\\"ismargin\\\":false,\\\"dontmargin\\\":false,\\\"solveInProgress\\\":0,\\\"solvedCount\\\":0,\\\"solveKey\\\":\\\"default\\\"}}\",\"smallData\":\"{}\",\"solvable\":1,\"tags\":\"[\\\"VARIABLE\\\"]\",\"timestamp\":$(JSON.json(v.timestamp)),\"_version\":\"0.18.1\"}"

  v = Variable("x0", :Point2)
  @test JSON.json(v) == "{\"label\":\"x0\",\"dataEntry\":\"{}\",\"nstime\":\"0\",\"variableType\":\"RoME.Point2\",\"dataEntryType\":\"{}\",\"ppeDict\":\"{}\",\"solverDataDict\":\"{\\\"default\\\":{\\\"vecval\\\":[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],\\\"dimval\\\":2,\\\"vecbw\\\":[0.0,0.0],\\\"dimbw\\\":2,\\\"BayesNetOutVertIDs\\\":[],\\\"dimIDs\\\":[0,1],\\\"dims\\\":2,\\\"eliminated\\\":false,\\\"BayesNetVertID\\\":\\\"_null\\\",\\\"separator\\\":[],\\\"variableType\\\":\\\"RoME.Point2\\\",\\\"initialized\\\":false,\\\"infoPerCoord\\\":[0.0,0.0],\\\"ismargin\\\":false,\\\"dontmargin\\\":false,\\\"solveInProgress\\\":0,\\\"solvedCount\\\":0,\\\"solveKey\\\":\\\"default\\\"}}\",\"smallData\":\"{}\",\"solvable\":1,\"tags\":\"[\\\"VARIABLE\\\"]\",\"timestamp\":$(JSON.json(v.timestamp)),\"_version\":\"0.18.1\"}"

  v = Variable("x0", "RoME.Pose2")
  @test JSON.json(v) == "{\"label\":\"x0\",\"dataEntry\":\"{}\",\"nstime\":\"0\",\"variableType\":\"RoME.Pose2\",\"dataEntryType\":\"{}\",\"ppeDict\":\"{}\",\"solverDataDict\":\"{\\\"default\\\":{\\\"vecval\\\":[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0],\\\"dimval\\\":3,\\\"vecbw\\\":[0.0,0.0,0.0],\\\"dimbw\\\":3,\\\"BayesNetOutVertIDs\\\":[],\\\"dimIDs\\\":[0,1,2],\\\"dims\\\":3,\\\"eliminated\\\":false,\\\"BayesNetVertID\\\":\\\"_null\\\",\\\"separator\\\":[],\\\"variableType\\\":\\\"RoME.Pose2\\\",\\\"initialized\\\":false,\\\"infoPerCoord\\\":[0.0,0.0,0.0],\\\"ismargin\\\":false,\\\"dontmargin\\\":false,\\\"solveInProgress\\\":0,\\\"solvedCount\\\":0,\\\"solveKey\\\":\\\"default\\\"}}\",\"smallData\":\"{}\",\"solvable\":1,\"tags\":\"[\\\"VARIABLE\\\"]\",\"timestamp\":$(JSON.json(v.timestamp)),\"_version\":\"0.18.1\"}"

end