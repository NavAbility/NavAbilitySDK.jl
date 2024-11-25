
GQL_START_WORKER = """
mutation startWorker(\$input: JSON = "", \$workerLabel: mutationInput_post_startWorker_workerLabel = addAffordance_kNNvisual) {
  startWorker(input: \$input, workerLabel: \$workerLabel)
}
"""
function startWorker(fgclient::NavAbilityDFG, workerLabel::String, payload)
    response = executeGql(
        fgclient,
        GQL_START_WORKER,
        Dict("workerLabel" => workerLabel, "input" => payload),
    )
    return response.data["startWorker"]["id"]
end
