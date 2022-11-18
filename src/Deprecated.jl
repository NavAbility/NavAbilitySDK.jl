
## =========================
## Remove below before v0.6
## =========================

@deprecate getData(client::NavAbilityClient, context::Client, fileId::AbstractString) getData(client, context, UUID(fileId))
@deprecate getDataByLabel( client::NavAbilityClient, context::Client, vlbl::AbstractString, w...; kw...) getData(client, context, vlbl, w...; kw...)

# Replaced by addVariablePacked
@deprecate addPackedVariable(navAbilityClient::NavAbilityClient, client::Client, variable) addPackedVariableOld(navAbilityClient, client, variable)
