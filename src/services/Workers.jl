
GQL_START_WORKER = """
mutation startWorker(\$input: JSON!, \$workerLabel: WorkerLabelEnum!) {
  startWorker(input: \$input, workerLabel: \$workerLabel)
}
"""
function startWorker(fgclient, workerLabel::String, payload)
    response = executeGql(
        fgclient,
        GQL_START_WORKER,
        Dict("workerLabel" => workerLabel, "input" => payload),
    )
    return response[:startWorker]["id"]
end
