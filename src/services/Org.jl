function getOrg(client::GQL.Client, label::Symbol)
    response = executeGql(
        client,
        GQL_GET_ORG,
        (label = label,),
        Vector{Org}
    )
    return response[:orgs][1]
end

function getOrgs(client::GQL.Client)
    response = executeGql(client, GQL_GET_ORGS, Dict(), Vector{Org})
    return response[:orgs]
end
