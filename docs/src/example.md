# [Usage Example](@id usage_example)

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

## Inspect an Existing Graph

Most use cases will involve retrieving information from a factor graph session already available on the server.

```julia
# also create a client connection
client = NavAbilityHttpsClient()

# create a client context user, robot, session
context = Client(
  # you need a unique userId:robotId, and can keep using that across all tutorials
  "guest@navability.io",
  "ExampleRobot",
  # You'll need a unique session number each time you run a new graph
  "Hexagonal",
)
```

### Variables

Variables represent state variables of interest such as vehicle or landmark positions, sensor calibration parameters, and more. Variables are likely hidden values that are not directly observed, but we want to estimate them from observed data.  Let's start by listing all the variables in the session:
```julia
varLbls = fetch(listVariables(client, context))
# ["l1","x0","x1","x2","x3","x4","x5","x6"]
```

The fetch call is used to wait on the underlying asynchronous call.

#### Data `BlobEntry=>Blob`

Additional data attached to variables exist in a few different ways.  The primary method for storing additional large data blobs with a variable, is to look at the `BlobEntry`s associated with a particular variable.  For example:
```julia
de = listDataEntries(client, context, "x0") |> fetch
```

Data blobs can be fetched via:
```julia
blob = getBlob(client, context, de.blobId)
```

!!! note
    All `blobId`s are unique across the entire distributed system, and are immutable.

### Factors

Factors represent the interaction between particular variables. Factors define the algebra structure between variables via probabilistic measurement models as captured measurement or data cues.  For example, a distance travelled measurement between two pose variables. Relative factors between variables are probabilistic models that capture the likelihood interactions between variables. Priors factors (i.e. unary to one variable) represent absolute information to be introduced about that variable, for example a GPS measurement; more on how to introduce distrust of such priors later.

