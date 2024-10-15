# TODO WIP
struct NavAbilityModel #<: AbstractNvaModel
    client::NavAbilityClient
    model::NvaNode{Model}
    agent::NvaNode{Agent}
    blobStores::Dict{Symbol, DFG.AbstractBlobStore}
end