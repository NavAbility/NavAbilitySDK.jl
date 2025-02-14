function getOrg(client::GQL.Client, label::Symbol)
    variables = Dict("label" => label)
    T = Vector{Org}
    response = executeGql(
        client,
        GQL_GET_ORG,
        variables,
        T
    )
    return response.data["orgs"][1]
end

function getOrgs(client::GQL.Client)
    T = Vector{Org}
    response = executeGql(client, GQL_GET_ORGS, Dict(), T)
    return response.data["orgs"]
end
