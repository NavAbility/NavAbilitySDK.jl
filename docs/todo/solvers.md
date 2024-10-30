# Graph Solvers

## Supported Solvers

NavAbility provides both **parametric** and **nonparametric** (i.e. non-Gaussian / multi-modal) factor graph solving solutions.  Please reach out via email <info@navability.io> or Slack [![](https://img.shields.io/badge/Invite-Slack-green.svg?style=popout)](https://join.slack.com/t/caesarjl/shared_invite/zt-ucs06bwg-y2tEbddwX1vR18MASnOLsw) if you would like to learn more about these features.

## Supported Probabily Models

### Gaussian Case

Parametric solving supports measurement models using the probability beliefs:
- `Normal`
- `MvNormal`

And also currently in beta:
- Max-`Mixture` of `Normal` or `MvNormal`

### Non-Gaussian Case

Non parametric solving can support a much wider range of measurement probability models.  Currently the SDK supports
- `Mixture`
- `Uniform`
- `Rayleigh`
- as well as multihypothesis features per factor -- i.e. `Categorical`.

Many more probability types are natively supported by the solver and yet directly exposed through the SDK, including
- Manifold Kernel Densities,
- Heatmaps or Intensity maps,
- Levelsets,
- Most common parametric probability models.

Reach out to NavAbility if you seek earlier SDK support for these or other more advanced probability features.

### Probability Model Index

```@docs
NvaSDK.Normal
NvaSDK.FullNormal
NvaSDK.Uniform
NvaSDK.Rayleigh
NvaSDK.MixtureData
```