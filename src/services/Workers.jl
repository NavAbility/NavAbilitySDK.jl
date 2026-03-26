#TODO delete GQL_START_WORKER
GQL_START_WORKER = """
mutation startWorker(\$input: JSON!, \$workerLabel: WorkerLabelEnum!) {
  startWorker(input: \$input, workerLabel: \$workerLabel)
}
"""
#TODO update GQL_OPS internal to use dispatchAction.
function dispatchAction(fgclient, workerLabel::String, payload)
    response = executeGql(
        fgclient,
        GQL_OPS[:dispatchAction],
        (workerLabel = workerLabel, input = payload),
    )
    return response[:startWorker]["id"]
end

@deprecate startWorker(args...) dispatchAction(args...)