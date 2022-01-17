[![Unit tests](https://github.com/NavAbility/NavAbilitySDK.jl/actions/workflows/tests.yml/badge.svg)](https://github.com/NavAbility/NavAbilitySDK.jl/actions/workflows/tests.yml)

# NavAbilitySDK.jl
Access NavAbility Cloud factor graph features from Julia.

Note that this SDK and the related API are still in development. Please let us know if you have any issues.

# Installation

Install the NavAbilitySDK using Pkg:

```
Pkg.add("NavAbilitySDK")
```

# Notes and FAQ

- **Which user should I use?** The Guest user is open and free for everyone to use. We recommend testing with this user, because it doesn't require any authentication. Note though, that the data is cleared on a regular basis, and that everyone can see your test data (all Guest users are created equal), so don't put anything in there that that is sensitive.
- **I have sensitive data, how do I create a user?** Great question, the NavAbility services completely isolate data per user and you can create a user at any point. At the moment we create users on demand because the services are changing as we develop them, and we want to make sure we can let everyone know as they do. Send us an email at [info@navability.io](mailto:info@navability.io) and we'll create a user for you right away.
- Otherwise for any questions, comments, or feedback please feel free to email us at [info@navability.io](mailto:info@navability.io) or write an issue on the repo.  

# Example

An example repo will be released in the near future. If you need support today, please reach out to [info@navability.io](mailto:info@navability.io)
