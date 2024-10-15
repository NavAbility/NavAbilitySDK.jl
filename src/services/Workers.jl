
GQL_START_WORKER= """
mutation startWorker(\$input: JSON = "", \$workerLabel: mutationInput_post_startWorker_workerLabel = addAffordance_kNNvisual) {
  startWorker(input: \$input, workerLabel: \$workerLabel)
}
"""
function startWorker(fgclient::NavAbilityDFG, workerLabel::String, payload)
    response = NvaSDK.GQL.execute(
        fgclient.client,
        GQL_START_WORKER,
        Dict;
        variables = Dict("workerLabel" => workerLabel, "input"=>payload),
        throw_on_execution_error = true,
    )
    return response.data["startWorker"]["id"]
end
