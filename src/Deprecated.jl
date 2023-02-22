
## =========================
## Remove below before v0.6
## =========================

@deprecate getDataEntry(w...;kw...) getBlobEntry(w...;kw...)
@deprecate getBlobEvent(w...;kw...) getBlobEvent(w...;kw...)
@deprecate getData(client::NavAbilityClient, context::Client, fileId::AbstractString) getData(client, context, UUID(fileId))
@deprecate getData(w...;kw...) getBlob(w...;kw...)

@deprecate listDataEntriesEvent(w...;kw...) listBlobEntriesEvent(w...;kw...)
@deprecate listDataEntries(w...;kw...) listBlobEntries(w...;kw...)
@deprecate listDataBlobsEvent(w...;kw...) listBlobsEvent(w...;kw...)
@deprecate listDataBlobs(w...;kw...) listBlobs(w...;kw...)

@deprecate addDataEntryEvent(args...;kwargs...) addBlobEntryEvent(args...;kwargs...)
@deprecate addDataEntry(w...;kw...) addBlobEntry(w...;kw...)
@deprecate addData(w...;kw...) addBlob(w...;kw...)

@deprecate getDataByLabel( client::NavAbilityClient, context::Client, vlbl::AbstractString, w...; kw...) getData(client, context, vlbl, w...; kw...)

# Replaced by addVariablePacked
@deprecate addPackedVariable(navAbilityClient::NavAbilityClient, client::Client, variable) addPackedVariableOld(navAbilityClient, client, variable)
