function exampleGraph1D(fgclient; doSolve = false)
    variables = [
        Variable(:x0, "ContinuousScalar"),
        Variable(:x1, "ContinuousScalar"),
        Variable(:x2, "ContinuousScalar"),
        Variable(:x3, "ContinuousScalar"),
    ]
    factors = [
        Factor([:x0], NvaSDK.Prior(NvaSDK.Normal(0, 1))),
        Factor([:x0, :x1], NvaSDK.LinearRelative(NvaSDK.Normal(10, 0.1))),
        #Factor(
        #    [:x1, :x2],
        #    Mixture(
        #        "LinearRelative",
        #        (; hypo1 = NvaSDK.Normal(0, 2), hypo2 = NvaSDK.Uniform(30, 55)),
        #        [0.4, 0.6],
        #        2,
        #    ),
        #),
        Factor([:x2, :x3],NvaSDK.LinearRelative(NvaSDK.Normal(-50, 1))),
        Factor([:x3, :x0], NvaSDK.LinearRelative(NvaSDK.Normal(40, 1))),
    ]
    # Variables
    @info "[Fixture] Adding variables, waiting for completion"
    resultIds = Task[]
    retvars = map(variables) do v
        addVariable!(fgclient, v)
    end
    
    # Add the factors
    @info "[Fixture] Adding factors, waiting for completion"
    retfacs = map(factors) do f
        addFactor(fgclient, f)
    end
    
    if doSolve
        @info "[Fixture] solving, waiting for completion"
        resultId = solveSession(fgclient)
        waitForCompletion(client, Task[resultIds;]; expectedStatuses = ["Complete"])
    end

    # and done
    return (fgclient, retvars, retfacs)
end
# vals = getVariables(client, context; detail=SUMMARY) .|> x->x["ppes"][1]["suggested"]

# @pytest.fixture(scope="module")
# async def example_1d_graph_solved(example_1d_graph):
#     """Get the graph after it has been solved.
#     NOTE this changes the graph, so tests need to be defensive.
#     """
#     navability_https_client, client, variables, factors = example_1d_graph
#     logging.info(f"[Fixture] Solving graph, client = {client.dumps()}")
#     requestId = await solveSession(navability_https_client, client)
#     await waitForCompletion(navability_https_client, [requestId], maxSeconds=180)
#     return (navability_https_client, client, variables, factors)

# @pytest.fixture(scope="module")
# async def example_2d_graph(
#     navability_https_client: NavAbilityClient, client_2d: Client
# ):
#     variables = [
#         Variable("x0", VariableType.Pose2.value),
#         Variable("x1", VariableType.Pose2.value),
#         Variable("x2", VariableType.Pose2.value),
#         Variable("l0", VariableType.Point2.value),
#     ]
#     factors = [
#         Factor(
#             "x0f1",
#             "PriorPose2",
#             ["x0"],
#             FactorData(
#                 fnc=PriorPose2(
#                     FullNormal(np.zeros(3), np.diag([0.1, 0.1, 0.1]))
#                 ).dump()  # This is a generator for a PriorPose2
#             ),
#         ),
#         Factor(
#             "x0x1f1",
#             "Pose2Pose2",
#             ["x0", "x1"],
#             FactorData(
#                 fnc=Pose2Pose2(
#                     FullNormal([1, 1, np.pi / 3], np.diag([0.1, 0.1, 0.1]))
#                 ).dump()  # This is a generator for a PriorPose2
#             ),
#         ),
#         Factor(
#             "x1x2f1",
#             "Pose2Pose2",
#             ["x1", "x2"],
#             FactorData(
#                 fnc=Pose2Pose2(
#                     FullNormal([1, 1, np.pi / 3], np.diag([0.1, 0.1, 0.1]))
#                 ).dump()  # This is a generator for a PriorPose2
#             ),
#         ),
#         # TODO: Improve problem setup in future.
#         Factor(
#             "l0f1",
#             "PriorPoint2",
#             ["l0"],
#             FactorData(
#                 fnc=PriorPoint2(FullNormal(np.asarray([5, 0]), np.diag([2, 2]))).dump()
#             ),
#         ),
#         Factor(
#             "x0l0f1",
#             "Point2Point2Range",
#             ["x0", "l0"],
#             FactorData(fnc=Point2Point2Range(Normal(5, 0.1)).dump()),  # Range
#         ),
#         Factor(
#             "x0l0f2",
#             "Pose2Point2BearingRange",
#             ["x0", "l0"],
#             FactorData(
#                 fnc=Pose2Point2BearingRange(
#                     Normal(0, 0.3), Normal(5, 0.1)  # Bearing, range
#                 ).dump()
#             ),
#         ),
#     ]
#     # Variables
#     result_ids = [
#         await addVariable!(navability_https_client, client_2d, v) for v in variables
#     ] + [await addFactor(navability_https_client, client_2d, f) for f in factors]

#     logging.info(f"[Fixture] Adding variables and factors, waiting for completion")

#     # Await for only Complete messages, otherwise fail.
#     await waitForCompletion(
#         navability_https_client,
#         result_ids,
#         expectedStatuses=["Complete"],
#         maxSeconds=120,
#     )

#     return (navability_https_client, client_2d, variables, factors)

# @pytest.fixture(scope="module")
# async def example_2d_graph_solved(example_2d_graph):
#     """Get the graph after it has been solved.
#     NOTE this changes the graph, so tests need to be defensive.
#     """
#     navability_https_client, client, variables, factors = example_2d_graph
#     logging.info(f"[Fixture] Solving graph, client = {client.dumps()}")
#     requestId = await solveSession(navability_https_client, client)
#     await waitForCompletion(navability_https_client, [requestId], maxSeconds=180)
#     return (navability_https_client, client, variables, factors)
