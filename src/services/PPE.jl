# =========================================================================================
# PPE CRUD
# =========================================================================================

function getPPE(fgclient::NavAbilityDFG, variableLabel::Symbol, solveKey::Symbol = :default)

    id = getId(fgclient.fg, variableLabel, solveKey)

    T = Vector{DFG.MeanMaxPPE}

    response = GQL.execute(fgclient.client.client,
        GQL_GET_PPE,
        T; 
        variables = (id=id,), 
        throw_on_execution_error = true
    )
    return handleQuery(response, "ppes", solveKey)
end

function getPPEs(fgclient::NavAbilityDFG, variableLabel::Symbol)
    id = getId(fgclient.fg, variableLabel)
    T = Vector{@NamedTuple{ppes::Vector{DFG.MeanMaxPPE}}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_GET_PPES,
        T;
        variables = (id=id,),
        throw_on_execution_error = true,
    )

    return handleQuery(response, "variables", :ppes)[1]
end

function addPPE!(fgclient::NavAbilityDFG, variableLabel::Symbol, ppe::DFG.MeanMaxPPE)
    addPPEs!(fgclient, variableLabel, [ppe])[1]
end

function addPPEs!(fgclient::NavAbilityDFG, variableLabel::Symbol, ppes::Vector{DFG.MeanMaxPPE})

    varId = getId(fgclient.fg, variableLabel)
    connect = createConnect(varId)

    # TODO we can probably standardise this
    input = map(ppes) do ppe
        return PPECreateInput(;
            getCommonProperties(PPECreateInput, ppe)...,
            id = getId(fgclient.fg, variableLabel, ppe.solveKey),
            variable = connect,
        )
    end

    T = @NamedTuple{ppes::Vector{DFG.MeanMaxPPE}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_ADD_PPES,
        # PPEResponse;
        T;
        variables = (ppes=input,),
        throw_on_execution_error = true,
    )
    return handleMutate(response, "createPpes", :ppes)
end

#TODO add if not exist, should now be easy as the id is deterministic
function updatePPE!(fgclient::NavAbilityDFG, varLabel::Symbol, ppe::MeanMaxPPE)

    varId = getId(fgclient.fg, varLabel)

    connect = createConnect(varId)
    id = getId(fgclient.fg, varLabel, ppe.solveKey)
    
    request = (
        getCommonProperties(PPECreateInput, ppe)...,
        id = id,
        variable = connect,
    )
    # Make request
    response = GQL.execute(
        fgclient.client.client,
        GQL_UPDATE_PPE,
        PPEResponse;
        variables = Dict("ppe" => request, "id" => id),
        throw_on_execution_error = true,
    )
    # Assuming one update, error if not
    numUpdated = length(response.data["updatePpes"].ppes)
    numUpdated != 1 && error("Expected to update one PPE but updated $(numUpdated)")
    return response.data["updatePpes"].ppes[1]
end

function deletePPE!(fgclient::NavAbilityDFG, varLabel::Symbol, ppe::DFG.MeanMaxPPE)
    id = getId(fgclient.fg, varLabel, ppe.solveKey)
    variables = (id=id,)

    response = GQL.execute(
        fgclient.client.client,
        GQL_DELETE_PPE;
        variables,
        throw_on_execution_error = true,
    )
    #TOOD check response.data["deleteSolverData"]["nodesDeleted"]
    return ppe
end

function deletePPE!(fgclient::NavAbilityDFG, varLabel::Symbol, solveKey::Symbol)
    ppe = getPPE(fgclient, varLabel, solveKey)
    return deletePPE!(fgclient, varLabel, ppe)
end

function listPPEs(fgclient::NavAbilityDFG, variableLabel::Symbol)
    id = getId(fgclient.fg, variableLabel)
    variables = (id=id,)

    # T = (NamedTuple{(:solveKey,), Tuple{Symbol}})
    T = Vector{Dict{String, Vector{@NamedTuple{solveKey::Symbol}}}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_LIST_PPES,
        T;
        variables,
        throw_on_execution_error = true,
    )
    return last.(handleQuery(response, "variables", variableLabel)["ppes"])
end
