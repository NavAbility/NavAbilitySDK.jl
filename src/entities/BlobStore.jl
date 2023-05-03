
#TODO we can also extend the blobstore
struct NavAbilityBlobStore <: DFG.AbstractBlobStore{Vector{UInt8}}
  key::Symbol
  client::GQL.Client
  userLabel::String
end

struct NavAbilityCachedBlobStore{T <: DFG.AbstractBlobStore} <:
    DFG.AbstractBlobStore{Vector{UInt8}}
  key::Symbol
  localstore::T
  remotestore::NavAbilityBlobStore
end