# =========================================================================================
# VariableSolverData CRUD
# =========================================================================================

function DFG.getVariableSolverData(
    fgclient::NavAbilityDFG,
    variableLabel::Symbol,
    solveKey::Symbol = :default,
)
    id = getId(fgclient.fg, variableLabel, solveKey)

    T = Vector{DFG.PackedVariableNodeData}

    response = GQL.execute(
        fgclient.client.client,
        GQL_GET_SOLVERDATA,
        T;
        variables=(id=id,),
        throw_on_execution_error = true,
    )

    return handleQuery(response, "solverData", solveKey)
end

function DFG.getVariableSolverDataAll(fgclient::NavAbilityDFG, variableLabel::Symbol)

    id = getId(fgclient.fg, variableLabel)
    T = Vector{@NamedTuple{solverData::Vector{DFG.PackedVariableNodeData}}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_GET_SOLVERDATA_ALL,
        T;
        variables = (id=id,),
        throw_on_execution_error = true,
    )

    return handleQuery(response, "variables", :solverData)[1]
end

function DFG.addVariableSolverData!(
    fgclient::NavAbilityDFG,
    variableLabel::Symbol,
    vnd::DFG.PackedVariableNodeData,
)
    return addVariableSolverData!(fgclient, variableLabel, [vnd])[1]
end

function DFG.addVariableSolverData!(
    fgclient::NavAbilityDFG,
    variableLabel::Symbol,
    vnds::Vector{DFG.PackedVariableNodeData},
)

    varId = getId(fgclient.fg, variableLabel)
    connect = createConnect(varId)

    # TODO we can probably standardise this
    input = map(vnds) do vnd
        return SolverDataCreateInput(;
            getCommonProperties(SolverDataCreateInput, vnd)...,
            id = getId(fgclient.fg, variableLabel, vnd.solveKey),
            variable = connect,
        )
    end

    T = @NamedTuple{solverData::Vector{PackedVariableNodeData}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_ADD_SOLVERDATA,
        T; #FIXME SolverDataResponse
        # SolverDataResponse;
        variables = (solverData=input,),
        throw_on_execution_error = true,
    )
    
    return handleMutate(response, "addSolverData", :solverData)
end

#TODO add if not exist, should now be easy as the id is deterministic
function DFG.updateVariableSolverData!(fgclient::NavAbilityDFG, varLabel::Symbol, vnd::DFG.PackedVariableNodeData)

    varId = getId(fgclient.fg, varLabel)

    connect = createConnect(varId)
    id = getId(fgclient.fg, varLabel, vnd.solveKey)
    
    request = (
        getCommonProperties(SolverDataCreateInput, vnd, [:id, :solveKey])...,
        variable = connect,
    )

    # Make request
    response = GQL.execute(
        fgclient.client.client,
        GQL_UPDATE_SOLVERDATA,
        SolverDataResponse;
        variables = Dict("solverData" => request, "id" => id),
        throw_on_execution_error = true,
    )
    # Assuming one update, error if not
    numUpdated = length(response.data["updateSolverData"].solverData)
    numUpdated != 1 && error("Expected to update one SolverData but updated $(numUpdated)")
    return response.data["updateSolverData"].solverData[1]
end

function DFG.deleteVariableSolverData!(fgclient::NavAbilityDFG, varLabel::Symbol, vnd::DFG.PackedVariableNodeData)

    id = getId(fgclient.fg, varLabel, vnd.solveKey)
    variables = (id=id,)

    response = GQL.execute(
        fgclient.client.client,
        GQL_DELETE_SOLVERDATA;
        variables,
        throw_on_execution_error = true,
    )
    #TOOD check response.data["deleteSolverData"]["nodesDeleted"]
    return vnd
end

function DFG.deleteVariableSolverData!(fgclient::NavAbilityDFG, varLabel::Symbol, solveKey::Symbol)
    vnd = getVariableSolverData(fgclient, varLabel, solveKey)
    return deleteVariableSolverData!(fgclient, varLabel, vnd)
end


function DFG.listVariableSolverData(fgclient::NavAbilityDFG, variableLabel::Symbol)
    
    id = getId(fgclient.fg, variableLabel)
    variables = (id=id,)

    # T = (NamedTuple{(:solveKey,), Tuple{Symbol}})
    T = Vector{Dict{String, Vector{@NamedTuple{solveKey::Symbol}}}}

    response = GQL.execute(
        fgclient.client.client,
        GQL_LIST_SOLVERDATA,
        T;
        variables,
        throw_on_execution_error = true,
    )

    return last.(handleQuery(response, "variables", variableLabel)["solverData"])

end