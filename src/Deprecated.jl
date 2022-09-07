
## =========================
## Remove below before v0.6
## =========================

@deprecate getDataByLabel( client::NavAbilityClient, context::Client, vlbl::AbstractString, w...; kw...) getData(client, context, vlbl, w...; kw...)
