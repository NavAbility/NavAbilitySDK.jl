# Cleanup: delete all variables and factors, then the graph and agent

# Delete factors first (required before variables can be removed)
for fl in listFactors(fgclient)
    deleteFactor!(fgclient, fl)
end
@test isempty(listFactors(fgclient))

# Delete all variables
for vl in listVariables(fgclient)
    deleteVariable!(fgclient, vl)
end
@test isempty(listVariables(fgclient))

# Delete the test graph and agent
deleteGraph!(fgclient)
@test !(TEST_GRAPH_LABEL in listGraphs(client))

deleteAgent!(client, TEST_AGENT_LABEL)
@test !(TEST_AGENT_LABEL in listAgents(client))
