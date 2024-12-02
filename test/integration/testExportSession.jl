
function testExportSession(
    client = NvaSDK.NavAbilityHttpsClient(; authorize = false),
    context = NvaSDK.Client(
        "guest@navability.io",
        "TESTING",
        "EXPORTSESSION_" * (string(NvaSDK.uuid4())[1:4]),
    );
    buildNewGraph::Bool = false,
)
    #
    if buildNewGraph
        # build a graph
        resultId =
            NvaSDK.addVariable!(client, context, NvaSDK.VariableDFG("x0", :Pose2)) |> fetch
        # Wait for them to be done before proceeding.
        @info "Wait on addVariable eventId" resultId
        NvaSDK.waitForCompletion(
            client,
            [resultId];
            expectedStatuses = ["Complete"],
            maxSeconds = 180,
        )

        eventId =
            NvaSDK.addFactor(
                client,
                context,
                NvaSDK.FactorDFG("x0f1", "PriorPose2", ["x0"], NvaSDK.PriorPose2Data()),
            ) |> fetch
        @info "Wait on addFactor eventId" resultId

        NvaSDK.waitForCompletion(
            client,
            [eventId];
            expectedStatuses = ["Complete"],
            maxSeconds = 180,
        )
    end

    # export the graph
    # eventId = NvaSDK.exportSession(client, context, "testexport.tar.gz",
    #                             options=NvaSDK.ExportSessionOptions(
    #                               format="NVA" # TODO TARGZ
    #                             )) |> fetch

    # @info "waiting for export Session" eventId
    # NvaSDK.waitForCompletion2(client, eventId)
    # blobId = NvaSDK.getExportSessionBlobId(client, eventId)
    # @info "Success: Here is the blobId you can use to download: $blobId"
end

function runExportTests(client, context)
    @testset "test exportSession" begin
        @info "Running test exportSession"

        testExportSession(client, context; buildNewGraph = false)
    end
end
