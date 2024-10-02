
## =========================
## Deprecated in v0.8
## =========================
export DFGClient, NavAbilityClient

DFGClient(args...; kwargs...) = error("DFGClient is deprecated, use NavAbilityDFG instead")

#TODO DEPRECATE add orgId
NavAbilityClient(args...; kwargs...) = error("Deprecated: NavAbilityClient requires and orgId")

# #FIXME DEPRECATE DFGClient(client::GQL.Client, context::Context, storeLabel=:NAVABILITY)
# function DFGClient(client::GQL.Client, context::Context, storeLabel=:NAVABILITY)
#     return DFGClient{DFG.Variable, DFG.PackedFactor}(
#         client,
#         (id = context.user.id, label = context.user.label),
#         (id = context.robot.id, label = context.robot.label),
#         (id = context.session.id, label = context.session.label),
#         Dict{Symbol, DFG.AbstractBlobStore}(
#             storeLabel => NavAbilityBlobStore(client, context.user.label),
#         ),
#     )
# end

# FIXME DEPRECATE
# function DFGClient(
#     userLabel::String,
#     robotLabel::String,
#     sessionLabel::String;
#     apiUrl::String = "https://api.navability.io",
#     auth_token::String = "",
#     authorize::Bool = 0 !== length(auth_token),
#     addRobotIfNotExists = false,
#     addSessionIfNotExists = false,
# )