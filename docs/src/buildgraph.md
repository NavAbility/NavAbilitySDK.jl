# Build a new Factor graph

The NavAbilitySDK provides variables and factors useful to robotics.  We start with a `Pose2` variable, i.e. position and orientation for a vehicle traveling on a flat XY plane.  

As before, let's setup a new client-context to talk with the NavAbility platform:
```julia
# also create a client connection
client = NavAbilityHttpsClient()

# create a client context user, robot, session
context = Client(
  "guest@navability.io",
  "ExampleRobot",
  "SDKjl_"*(string(uuid4())[1:4]),
)
```

## First Pose

The `addVariable` function with a label `"x0"` and type `:Pose2` adds that variable to  to the factor graph.

```julia
# let's collect all the async responses and wait at the end
resultIds = Task[]
# addVariable and keep the transaction ID
push!(resultIds, 
  addVariable(client, context, "x0", :Pose2)
);
```

Note that asynchronous tasks are used to increase the upload performance.  Each of these events are queued on the server for processing.  While the variable is being created, let's also add a prior factor.

We now have a factor graph with one variable, but to solve it we need some additional information.  In this example, we need the estimated starting point of our robot.
We use unary factors called priors to represent absolute information to be introduced.  In this case we use `PriorPose2`, as our variable type is also `Pose2`.
Since factors represent a probabilistic interaction between variables, we need to specify the distribution our factor will represent. Here we use `FullNormal` which is a [multivariate normal distribution](https://en.wikipedia.org/wiki/Multivariate_normal_distribution). 

Let's create a `PriorPose2` unary factor with zero mean and a covariance matrix of (`diagm([0.05,0.05,0.01].^2)`):
```julia
push!(
  resultIds, 
  addFactor(
    client, context, ["x0"], 
    NVA.PriorPose2(;
      Z=FullNormal(
        [0.0, 0.0, 0.0], 
        diagm([0.05, 0.05, 0.01].^2)
      )
    )
  )
)
```

After adding a batch of variables and factors, we can wait on the upload status to ensure the new graph elements have been processed:
```julia
# wait to make sure all nodes were added
waitForCompletion(client, resultIds; expectedStatuses=["Complete"])
```

As before, we can use the NavAbility App to visualize the factor graph
```julia
# Click on the generated URL or graphic to open the NavAbility App Graph visualization page for this session
GraphVizApp(context, variableStartsWith="")
```

## Odometry Factor

An odometry factor connects two consecutive robot poses `x0` and `x1` together to form a chain.  Here we use a relative factor of type `Pose2Pose2` with a measurement from pose `x0` to `x1` of `(x=1.0,y=0.0,θ=pi/2)`; the robot drove 1 unit forward (in the x direction).  Similarly to the prior we added above, we use a `FullNormal` distribution to represent the odometry with mean and covariance:
```julia
# reset waiting list
resultIds = Task[]
# add x1
push!(resultIds, 
  addVariable(client, context, "x1", :Pose2)
)

# add odometry measurement between x0 and x1
push!(
  resultIds, 
  addFactor(client, context, ["x0","x1"],
    NVA.Pose2Pose2(;
      Z=FullNormal(
        [1.0, 0.0, pi/2], 
        diagm([0.1, 0.1, 0.01].^2)
      )
    )
  )
);
```

## Adding Different Sensors

So far we worked with the `Pose2` factor type.  Among others, `NavAbilitySDK` also provides the `Point2` variable and `Pose2Point2BearingRange` factor types, which we will use to represent a landmark sighting in our factor graph.  We will add a landmark `l1` with bearing range measurement of bearing=`(mu=0,sigma=0.03)` `range=(mu=0.5,sigma=0.1)` and continue our robot trajectory by driving around in a square.
```julia
# add one landmark
push!(resultIds,
  addVariable(client, context, "l1", :Point2))

# add three more poses
for x in ["x2"; "x3"; "x4"]
  push!(resultIds,
    addVariable(client, context, x, :Pose2))
end

## add Factors

# add landmark observation measurement and
push!(resultIds, 
  addFactor(client, context, ["x0","l1"], 
    NVA.Pose2Point2BearingRange(Normal(0, 0.03), Normal(0.5, 0.1))))    
  
# odometry measurements between poses
push!(resultIds, 
  addFactor(client, context, ["x1","x2"], 
    NVA.Pose2Pose2(
      FullNormal(
       [1.0, 0.0, pi/2], 
       diagm([0.1, 0.1, 0.01].^2)))))

push!(resultIds, 
  addFactor(client, context, ["x2","x3"], 
    NVA.Pose2Pose2(
      FullNormal(
       [1.0, 0.0, pi/2], 
       diagm([0.1, 0.1, 0.01].^2)))))

push!(resultIds, 
  addFactor(client, context, ["x3","x4"], 
    NVA.Pose2Pose2(
      FullNormal(
        [1.0, 0.0, pi/2], 
        diagm([0.1, 0.1, 0.01].^2)))))

# let's wait to make sure all the new additions are ready
waitForCompletion(client, resultIds; expectedStatuses=["Complete"])
```

## One Loop-Closure Example

The robot continued its square trajectory to end off where it started.  To illustrate a loop closure, we add another bearing range sighting to from pose `x4` to landmark `l1`, solve the graph and plot the new results: 
```julia
resultIds = Task[]
# add a loop closure landmark observation
push!(
  resultIds,
  addFactor(
    client, context, 
    ["x4","l1"], 
    NVA.Pose2Point2BearingRange(
      Normal(0, 0.03), 
      Normal(0.5, 0.1))
  )
);

# let's wait to make sure all the new additions are ready
waitForCompletion(client, resultIds; expectedStatuses=["Complete"])
```