# [Getting Started](@id getting_started)

NavAbility fundamentally organizes mapping, localization, and perception data (a.k.a. navigation data) by means of a visual graphical model known as factor graphs.  See the related documentation on [Graph Concepts](https://juliarobotics.org/Caesar.jl/latest/concepts/concepts/) for more information about what factor graphs.

## Free [`guest@navability.io`] access

A free tier access to NavAbility servers is provided through the user `guest@navability.io`.  To learn more about using the guest user, consider trying the [NavAbilty Tutorials](https://app.navability.io/get-started/tutorials).

## [Privacy and Auth Token](@id auth_token)

A user specific authentication token is needed whether you are just accessing an existing graph, modifying, adding data, or building a whole new graph directly through the SDK.  At present, the only way to obtain a temporary authentication token is through the [NavAbility App on the "Connect" page](https://app.navability.io/edge/connect) (or from the App, use the burger menu top left to access the Connect page).  A user login to NavAbility is needed before an auth token can be provided.  Auth tokens last for 24 hours, and should be kept private to each session or usage.  Do not store or share the token with others.  See below for getting a login if you do not already have one.

## NavAbility App Login

You can login via the [NavAbility App](https://app.navability.io/get-started/introduction/) by clicking on the account menu top right.  please do reach out if you have any questions via Slack [![](https://img.shields.io/badge/Invite-Slack-green.svg?style=popout)](https://join.slack.com/t/caesarjl/shared_invite/zt-ucs06bwg-y2tEbddwX1vR18MASnOLsw), emailing us at <info@navability.io>, or [filing specific issues against the SDK](https://github.com/NavAbility/NavAbilitySDK.jl/issues).

```@raw html
<a href="https://app.navability.io/get-started/introduction/">
<p align="center">
<img src="https://user-images.githubusercontent.com/6412556/218193635-2325bbd1-f82c-4391-8959-8f54b2acdc0a.png" width="240" border="0" />
</p>
</a>
```

## Installing

The NavAbilitySDK can be installed as a usual Julia package:
```julia
import Pkg; Pkg.add("NavAbilitySDK")
```

## Loading NavAbilitySDK

Loading the SDK module:
```julia
using NavAbilitySDK
```

Alternatively, you can also avoid populating the namespace via import:
```julia
import NavAbilitySDK as NvaSDK
```

!!! note
    The NavAbility and [Caesar.jl](https://juliarobotics.org/Caesar.jl/latest/) design promote distributed factor graph workflows for both edge and cloud usage.  The NavAbilitySDK is part of a larger architecture where both client and server side computations are used.  The rest of this page illustrates usage against the server side data and computations.  Reach out to NavAbility via Slack [![](https://img.shields.io/badge/Invite-Slack-green.svg?style=popout)](https://join.slack.com/t/caesarjl/shared_invite/zt-ucs06bwg-y2tEbddwX1vR18MASnOLsw) or <info@navability.io> for more help.
