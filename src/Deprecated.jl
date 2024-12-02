
## =========================
## Deprecated in v0.8
## =========================
export DFGClient, NavAbilityClient

DFGClient(args...; kwargs...) = error("DFGClient is deprecated, use NavAbilityDFG instead")

#TODO DEPRECATE add orgId
NavAbilityClient(args...; kwargs...) = error("Deprecated: NavAbilityClient requires a auth_token")

# FIXME DEPRECATED
struct Context end
Context(a...; ka...) = error("deprecated")

listBlobsMeta(args...) = error("listBlobsMeta is deprecated, use BlobEntries")
listBlobsId(args...) = error("listBlobsId is deprecated, use listBlobs")
