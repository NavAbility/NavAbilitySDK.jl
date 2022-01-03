using ..NavAbilitySDK

function solveSession(navAbilityClient::NavAbilityClient, client::Client)
    navAbilityClient.mutate(MutationOptions(
        "solveSession",
        MUTATION_SOLVESESSION,
        Dict(
            "client" => client,
        )
    ))
end

function solveFederated(navAbilityClient::NavAbilityClient, scope::Scope )
    navAbilityClient.mutate(MutationOptions(
        "solveFederated",
        MUTATION_SOLVEFEDERATED,
        Dict(
            "scope" => scope,
        )
    ))
end