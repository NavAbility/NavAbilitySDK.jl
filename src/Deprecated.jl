
## =========================
## Remove below before v0.6
## =========================

@deprecate getData(client::NavAbilityClient, context::Client, fileId::AbstractString) getData(client, context, UUID(fileId))
@deprecate getDataByLabel( client::NavAbilityClient, context::Client, vlbl::AbstractString, w...; kw...) getData(client, context, vlbl, w...; kw...)
