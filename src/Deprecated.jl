
## =========================
## Deprecated in v0.9
## =========================

# consolidated with NavAbilityBlobStore, which can be used for both on-prem and cloud deployments.
function NavAbilityOnPremBlobStore(client, label=:default)
    Base.depwarn("NavAbilityOnPremBlobStore is consolidated with NavAbilityBlobStore, use NavAbilityBlobStore instead.", :NavAbilityOnPremBlobStore)
    return NavAbilityBlobStore(client, label)
end