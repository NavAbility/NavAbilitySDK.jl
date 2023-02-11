var documenterSearchIndex = {"docs":
[{"location":"factors/#work_w_factors","page":"Factors","title":"Working with Factors","text":"","category":"section"},{"location":"factors/","page":"Factors","title":"Factors","text":"Factors represent the interaction between particular variables. Factors define the algebra structure between variables via probabilistic measurement models as captured measurement or data cues.  For example, a distance travelled measurement between two pose variables. Relative factors between variables are probabilistic models that capture the likelihood interactions between variables. Priors factors (i.e. unary to one variable) represent absolute information to be introduced about that variable, for example a GPS measurement; more on how to introduce distrust of such priors later.","category":"page"},{"location":"variables/#work_w_variables","page":"Variables","title":"Working with Variables","text":"","category":"section"},{"location":"variables/#Inspect-an-Existing-Graph","page":"Variables","title":"Inspect an Existing Graph","text":"","category":"section"},{"location":"variables/","page":"Variables","title":"Variables","text":"Most use cases will involve retrieving information from a factor graph session already available on the server.","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"# also create a client connection\nclient = NavAbilityHttpsClient()\n\n# create a client context user, robot, session\ncontext = Client(\n  # you need a unique userId:robotId, and can keep using that across all tutorials\n  \"guest@navability.io\",\n  \"ExampleRobot\",\n  # You'll need a unique session number each time you run a new graph\n  \"Hexagonal\",\n)","category":"page"},{"location":"variables/#Variables","page":"Variables","title":"Variables","text":"","category":"section"},{"location":"variables/","page":"Variables","title":"Variables","text":"Variables represent state variables of interest such as vehicle or landmark positions, sensor calibration parameters, and more. Variables are likely hidden values that are not directly observed, but we want to estimate them from observed data.  Let's start by listing all the variables in the session:","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"varLbls = fetch(listVariables(client, context))\n# [\"l1\",\"x0\",\"x1\",\"x2\",\"x3\",\"x4\",\"x5\",\"x6\"]","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"The fetch call is used to wait on the underlying asynchronous call.","category":"page"},{"location":"variables/#Data-BlobEntryBlob","page":"Variables","title":"Data BlobEntry=>Blob","text":"","category":"section"},{"location":"variables/","page":"Variables","title":"Variables","text":"Additional data attached to variables exist in a few different ways.  The primary method for storing additional large data blobs with a variable, is to look at the BlobEntrys associated with a particular variable.  For example:","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"de = listBlobEntries(client, context, \"x0\") |> fetch\nde .|> s->s.blobLabel\n# e.g. [\"Camera0\", \"user_calibration\", etc.]","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"Data blobs can be fetched via, e.g. using the unique blobId of the first dataEntry on this variable:","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"blob = getBlob(client, context, de[1].blobId)","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"Data blobs are provided in binary format (i.e. ::Vector{UInt8}).","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"note: Note\nAll blobIds are unique across the entire distributed system and are immutable.","category":"page"},{"location":"variables/#Numerical-Solution","page":"Variables","title":"Numerical Solution","text":"","category":"section"},{"location":"variables/","page":"Variables","title":"Variables","text":"The main purpose of using a factor graph is not only as data index but also to deeply connect with the mapping and localization problem.  Variables in the factor graph represent the states to be estimated from the relevant measurement data.  The numerical values for each variable are computed by any number of solver operations.  The numerical results are primarily stored in a variables solverData field, such that either parametric or non-parametric inference results can be used:","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"v0 = getVariable(client, context, \"x0\")","category":"page"},{"location":"variables/#Understanding-solveKeys","page":"Variables","title":"Understanding solveKeys","text":"","category":"section"},{"location":"variables/","page":"Variables","title":"Variables","text":"Since various numerical solutions may exists for the same factor graph, we introduce the idea of a solveKey.  Different numerical values for different solveKeys can exists for any number of reasons.  Using the example from above, we might find:","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"v0[\"solverData\"][1][\"solveKey\"]\n# graphinit\nv0[\"solverData\"][2][\"solveKey\"]\n# default\nv0[\"solverData\"][3][\"solveKey\"]\n# parametric","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"Each of these solverDatas are unique identified via the solveKey.  The graphinit solver values are a duplicate of the numerical values for the variable before inference computation was performed.  In this example the default key corresponds to the nonparametric solution, and parametric represents a Gaussian only parametric solution.","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"The numerical values can be obtained from the solverData via:","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"v0[\"solverData\"][3][\"vecval\"]\n# [-0.001, 0.002, 0.001]","category":"page"},{"location":"variables/#Understanding-PPEs","page":"Variables","title":"Understanding PPEs","text":"","category":"section"},{"location":"variables/","page":"Variables","title":"Variables","text":"To better bridge the gap between non-Gaussian and Gaussian solutions, variables also store a convenience numerical solution called the parametric point estimate (PPE) for each of the solveKeys.  While various forms of PPEs can exists–-such as mean, max, modes, etc.–-a common suggested field exists for basic usage.  For example, the suggested parametric equivalent solution from the nonparametric solver (default) can be obtained by:","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"xyr = v0[\"ppes\"][2][\"suggested\"]\n# [-0.00, 0.00, 0.00]","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"warning: Warning\nAt time of writing these numerical values represent the solution stored in coordinates.  In the future, these values are expected to stored directly as on-manifold point representations.  The internal solver computations are already all on-manifold.  For more information, see the on-manifold points, tangent vectors, and coordinates description presented here.","category":"page"},{"location":"variables/#SDK-Supported-Variables","page":"Variables","title":"SDK Supported Variables","text":"","category":"section"},{"location":"variables/","page":"Variables","title":"Variables","text":"The list of variable types currently supported by the SDK are:","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"Position1 / ContinuousScalar\nPosition2 / Point2\nPose2\nPosition3 / Point3\nPose3","category":"page"},{"location":"variables/","page":"Variables","title":"Variables","text":"note: Note\nMany more variable types are already supported by the solver, see additional docs here.  Reach out to NavAbility for help or support in bringing more variable types to the SDK sooner, or for help in building more variable types that may not yet exist in either libraries.","category":"page"},{"location":"buildgraph/#Build-a-new-Factor-graph","page":"Build a Graph","title":"Build a new Factor graph","text":"","category":"section"},{"location":"buildgraph/","page":"Build a Graph","title":"Build a Graph","text":"NavAbilitySDK.jl provides variables and factors useful to robotics. We start with a Pose2 variable, i.e. position and orientation in two dimensions. Call addVariable with a label x0 and type Pose2 to add variables to the factor graph","category":"page"},{"location":"start/#getting_started","page":"Getting Started","title":"Getting Started","text":"","category":"section"},{"location":"start/","page":"Getting Started","title":"Getting Started","text":"NavAbility fundamentally organizes mapping, localization, and perception data (a.k.a. navigation data) by means of a visual graphical model known as factor graphs.  See the related documentation on Graph Concepts for more information about what factor graphs.","category":"page"},{"location":"start/#Free-[guest@navability.io]-access","page":"Getting Started","title":"Free [guest@navability.io] access","text":"","category":"section"},{"location":"start/","page":"Getting Started","title":"Getting Started","text":"A free tier access to NavAbility servers is provided through the user guest@navability.io.  To learn more about using the guest user, consider trying the NavAbilty Tutorials.","category":"page"},{"location":"start/#auth_token","page":"Getting Started","title":"Privacy and Auth Token","text":"","category":"section"},{"location":"start/","page":"Getting Started","title":"Getting Started","text":"A user specific authentication token is needed whether you are just accessing an existing graph, modifying, adding data, or building a whole new graph directly through the SDK.  At present, the only way to obtain a temporary authentication token is through the NavAbility App on the \"Connect\" page (or from the App, use the burger menu top left to access the Connect page).  A user login to NavAbility is needed before an auth token can be provided.  Auth tokens last for 24 hours, and should be kept private to each session or usage.  Do not store or share the token with others.  See below for getting a login if you do not already have one.","category":"page"},{"location":"start/#NavAbility-App-Login","page":"Getting Started","title":"NavAbility App Login","text":"","category":"section"},{"location":"start/","page":"Getting Started","title":"Getting Started","text":"You can login via the NavAbility App by clicking on the account menu top right.  please do reach out if you have any questions via Slack (Image: ), emailing us at <info@navability.io>, or filing specific issues against the SDK.","category":"page"},{"location":"start/","page":"Getting Started","title":"Getting Started","text":"<a href=\"https://app.navability.io/get-started/introduction/\">\n<p align=\"center\">\n<img src=\"https://user-images.githubusercontent.com/6412556/218193635-2325bbd1-f82c-4391-8959-8f54b2acdc0a.png\" width=\"240\" border=\"0\" />\n</p>\n</a>","category":"page"},{"location":"start/#Installing","page":"Getting Started","title":"Installing","text":"","category":"section"},{"location":"start/","page":"Getting Started","title":"Getting Started","text":"The NavAbilitySDK can be installed as a usual Julia package:","category":"page"},{"location":"start/","page":"Getting Started","title":"Getting Started","text":"import Pkg; Pkg.add(\"NavAbilitySDK\")","category":"page"},{"location":"start/#Loading-NavAbilitySDK","page":"Getting Started","title":"Loading NavAbilitySDK","text":"","category":"section"},{"location":"start/","page":"Getting Started","title":"Getting Started","text":"Loading the SDK module:","category":"page"},{"location":"start/","page":"Getting Started","title":"Getting Started","text":"using NavAbilitySDK","category":"page"},{"location":"start/","page":"Getting Started","title":"Getting Started","text":"Alternatively, you can also avoid populating the namespace via import:","category":"page"},{"location":"start/","page":"Getting Started","title":"Getting Started","text":"import NavAbilitySDK as NvaSDK","category":"page"},{"location":"start/","page":"Getting Started","title":"Getting Started","text":"note: Note\nThe NavAbility and Caesar.jl design promote distributed factor graph workflows for both edge and cloud usage.  The NavAbilitySDK is part of a larger architecture where both client and server side computations are used.  The rest of this page illustrates usage against the server side data and computations.  Reach out to NavAbility via Slack (Image: ) or <info@navability.io> for more help.","category":"page"},{"location":"#NavAbilitySDK","page":"Home","title":"NavAbilitySDK","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Welcome to the NavAbilitySDK documentation.  Various NavAbilitySDKs exist for different programming languages.  This particular documentation set is for the Julia language package, however, there is strong consistency between the SDKs for various languages.  All the SDKs make standard, authenticated requests to the NavAbility servers, thereby enforcing consistency of operations.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Convenient links to other language NavAbilitySDKs:","category":"page"},{"location":"","page":"Home","title":"Home","text":"NavAbilitySDK.py\nNavAbilitySDK.js","category":"page"},{"location":"","page":"Home","title":"Home","text":"Next, see the Getting Started page.","category":"page"},{"location":"summary/","page":"Index","title":"Index","text":"CurrentModule = NavAbilitySDK","category":"page"},{"location":"summary/#SDK-function-Index","page":"Index","title":"SDK function Index","text":"","category":"section"},{"location":"summary/","page":"Index","title":"Index","text":"Documentation for NavAbilitySDK.","category":"page"},{"location":"summary/","page":"Index","title":"Index","text":"","category":"page"},{"location":"summary/","page":"Index","title":"Index","text":"Modules = [NavAbilitySDK]","category":"page"},{"location":"summary/#NavAbilitySDK.Categorical","page":"Index","title":"NavAbilitySDK.Categorical","text":"mutable struct Categorical <: Distribution\n\nCategorical distribution specified by a set of probabilities summing up to 1.\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.Client","page":"Index","title":"NavAbilitySDK.Client","text":"struct Client\n\nThe context for a session, made from a user, robot, and session. Users can have multiple robots and robots can have multiple sessions. So this indicates a unique session.\n\nDevNotes\n\nRename to SessionKey\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.Distribution","page":"Index","title":"NavAbilitySDK.Distribution","text":"abstract type Distribution\n\nAbstract parent type for all distributions.\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.FullNormal","page":"Index","title":"NavAbilitySDK.FullNormal","text":"mutable struct FullNormal <: Distribution\n\nMultidimensional normal distribution specified by means and a covariance matrix.\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.GraphVizApp","page":"Index","title":"NavAbilitySDK.GraphVizApp","text":"struct GraphVizApp\n\nHelper type for linking to App visualization of a factor graph for user:robot:session.\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.InferenceType","page":"Index","title":"NavAbilitySDK.InferenceType","text":"abstract type InferenceType\n\nAbstract parent type for all InferenceTypes, which are the functions inside of factors.\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.MapVizApp","page":"Index","title":"NavAbilitySDK.MapVizApp","text":"struct MapVizApp\n\nHelper type for linking to App visualization of geometric map for user:robot:session.\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.MixtureInferenceType","page":"Index","title":"NavAbilitySDK.MixtureInferenceType","text":"struct MixtureInferenceType <: NavAbilitySDK.InferenceType\n\nInferenceType for MixtureData.\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.Normal","page":"Index","title":"NavAbilitySDK.Normal","text":"mutable struct Normal <: Distribution\n\nOne dimensional normal distribution.\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.Pose2AprilTag4Corners","page":"Index","title":"NavAbilitySDK.Pose2AprilTag4Corners","text":"struct Pose2AprilTag4Corners <: NavAbilitySDK.InferenceType\n\nInferenceType for Pose2AprilTag4CornersData.\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.Pose2Point2BearingRange","page":"Index","title":"NavAbilitySDK.Pose2Point2BearingRange","text":"struct Pose2Point2BearingRange <: NavAbilitySDK.InferenceType\n\nPose2Point2BearingRangeInferenceType is used to represent a bearing\n\nrange measurement.\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.Rayleigh","page":"Index","title":"NavAbilitySDK.Rayleigh","text":"mutable struct Rayleigh <: Distribution\n\nOne dimensional Rayleigh distribution.\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.Scope","page":"Index","title":"NavAbilitySDK.Scope","text":"struct Scope\n\nSome calls interact across multiple users, robots, and sessions. A scope allows you to specify these more complex contexts.\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.SolveOptions","page":"Index","title":"NavAbilitySDK.SolveOptions","text":"struct SolveOptions\n\nSolver options including the solve key and whether the parametric solver should be used.\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.Uniform","page":"Index","title":"NavAbilitySDK.Uniform","text":"mutable struct Uniform <: Distribution\n\nOne dimensional uniform distribution.\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.ZInferenceType","page":"Index","title":"NavAbilitySDK.ZInferenceType","text":"struct ZInferenceType <: NavAbilitySDK.InferenceType\n\nZInferenceType is used by many factors as a common inference type that uses a single distribution to express a constraint between variables. Used by: Prior, LinearRelative, PriorPose2, PriorPoint2, Pose2Pose2, Point2Point2Range, etc.\n\n\n\n\n\n","category":"type"},{"location":"summary/#NavAbilitySDK.LinearRelativeData-Tuple{}","page":"Index","title":"NavAbilitySDK.LinearRelativeData","text":"LinearRelativeData(; Z, kwargs...)\n\n\nCreate a ContinousScalar->ContinousScalar (also known as Pose1->Pose1) factor with a distribution Z representing the 1D relationship between the variables, e.g. Normal(1.0, 0.1).\n\nDefault value of Z = Normal(1.0, 0.1).\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.MixtureData-Tuple{Any, NamedTuple, Vector{Float64}, Integer}","page":"Index","title":"NavAbilitySDK.MixtureData","text":"MixtureData(mechanics, components, probabilities, dims)\n\n\nCreate a Mixture factor type with an underlying factor type, a named set of distributions that should be mixed, the probabilities of each distribution (the mix), and the dimensions of the underlying factor (e.g. ContinuousScalar=1, Pose2Pose2=3, etc.).\n\nArgs:     mechanics (Type{FactorData}): The underlying factor data type, e.g. Pose2Pose2Data. NOTE: This will change in later versions      but for now it can be any of the FactorData classes (e,g, LinearRelative, not the object LinearRelative()).     components (NamedTuple): The named tuple set of distributions that     should be mixed, e.g. NamedTuple(hypo1=Normal(0, 2)), hypo2=Uniform(30, 55)).     probabilities (List[float]): The probabilities of each distribution (the mix), e.g. [0.4, 0.6].     dims (int): The dimensions of the underlying factor, e.g. for Pose2Pose2 it's 3.\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.NavAbilityHttpsClient","page":"Index","title":"NavAbilitySDK.NavAbilityHttpsClient","text":"NavAbilityHttpsClient()\nNavAbilityHttpsClient(apiUrl; auth_token, authorize)\n\n\nMain interactions with API for queries and mutations go through here.\n\nDevNotes\n\nTODO TBD, rather use upstream retry logic instead, \nsee https://github.com/JuliaWeb/HTTP.jl/pull/974/files\n\n\n\n\n\n","category":"function"},{"location":"summary/#NavAbilitySDK.Point2Point2RangeData-Tuple{}","page":"Index","title":"NavAbilitySDK.Point2Point2RangeData","text":"Point2Point2RangeData(; range, kwargs...)\n\n\nCreate a Point2->Point2 range factor with a 1D distribution:\n\nrange: The range from the pose to the point, default Normal(1, 1).\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.Pose2AprilTag4CornersData-Tuple{Any, Vector{Float64}, Vector{Float64}}","page":"Index","title":"NavAbilitySDK.Pose2AprilTag4CornersData","text":"Pose2AprilTag4CornersData(\n    id,\n    corners,\n    homography;\n    K,\n    taglength,\n    kwargs...\n)\n\n\nCreate a AprilTags factor that directly relates a Pose2 to the information from an AprilTag reading. Corners need to be provided, homography and tag length are defaulted and can be overwritten.\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.Pose2Point2BearingRangeData-Tuple{}","page":"Index","title":"NavAbilitySDK.Pose2Point2BearingRangeData","text":"Pose2Point2BearingRangeData(; bearing, range, kwargs...)\n\n\nCreate a Pose2->Point2 bearing+range factor with 1D distributions:\n\nbearing: The bearing from the pose to the point, default Normal(0, 1).\nrange: The range from the pose to the point, default Normal(1, 1).\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.Pose2Pose2Data-Tuple{}","page":"Index","title":"NavAbilitySDK.Pose2Pose2Data","text":"Pose2Pose2Data(; Z, kwargs...)\n\n\nCreate a Pose2->Pose2 factor with a distribution Z representing the (x,y,theta) relationship between the variables, e.g. FullNormal([1,0,0.3333*π], diagm([0.01,0.01,0.01])).\n\nDefault value of Z = FullNormal([1,0,0.3333*π], diagm([0.01,0.01,0.01])).\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.Pose3Pose3Data-Tuple{}","page":"Index","title":"NavAbilitySDK.Pose3Pose3Data","text":"Pose3Pose3Data(; Z, kwargs...)\n\n\nCreate a Pose3->Pose3 factor with a distribution Z representing the (x,y,theta) relationship between the variables, e.g. FullNormal([1;zeros(5)], diagm(0.01*ones(6))).\n\nDefault value of Z = FullNormal(zeros(6), diagm(0.01*ones(6))).\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.Pose3Pose3RotationData-Tuple{}","page":"Index","title":"NavAbilitySDK.Pose3Pose3RotationData","text":"Pose3Pose3RotationData(; Z, kwargs...)\n\n\nCreate a partial factor on Rotation only on Pose3->Pose3 with a distribution Z representing the relationship between the variables.\n\nDefault value of Z = FullNormal(zeros(3), diagm(0.01*ones(3))).\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.PriorData-Tuple{}","page":"Index","title":"NavAbilitySDK.PriorData","text":"PriorData(; Z, kwargs...)\n\n\nCreate a prior factor for a ContinuousScalar (a.k.a. Pose1) with a distribution Z representing 1D prior information,      e.g. Normal(0.0, 0.1).\n\nDefault value of Z = Normal(0.0, 0.1).\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.PriorPoint2Data-Tuple{}","page":"Index","title":"NavAbilitySDK.PriorPoint2Data","text":"PriorPoint2Data(; Z, kwargs...)\n\n\nCreate a prior factor for a Point2 with a distribution Z representing (x,y) prior information,      e.g. FullNormal([0.0, 0.0.0], diagm([0.01, 0.01])).\n\nDefault value of Z = FullNormal([0.0, 0.0], diagm([0.01, 0.01])).\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.PriorPose2Data-Tuple{}","page":"Index","title":"NavAbilitySDK.PriorPose2Data","text":"PriorPose2Data(; Z, kwargs...)\n\n\nCreate a prior factor for a Pose2 with a distribution Z representing (x,y,theta) prior information,      e.g. FullNormal([0.0, 0.0, 0.0], diagm([0.01, 0.01, 0.01])).\n\nDefault value of Z = FullNormal([0.0, 0.0, 0.0], diagm([0.01, 0.01, 0.01])).\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.PriorPose3Data-Tuple{}","page":"Index","title":"NavAbilitySDK.PriorPose3Data","text":"PriorPose3Data(; Z, kwargs...)\n\n\nCreate a prior factor for a Pose3 with a distribution Z representing (x,y,z,i,j,k) prior information,      e.g. FullNormal(zeros(6), diagm(0.01*ones(6))).\n\nDefault value of Z = FullNormal(zeros(6), diagm(0.01*ones(6))).\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.ScatterAlignPose2Data","page":"Index","title":"NavAbilitySDK.ScatterAlignPose2Data","text":"ScatterAlignPose2Data(varType, cloud1, cloud2)\nScatterAlignPose2Data(varType, cloud1, cloud2, bw1)\nScatterAlignPose2Data(\n    varType,\n    cloud1,\n    cloud2,\n    bw1,\n    bw2;\n    mkd1,\n    mkd2,\n    kw_sap,\n    kwargs...\n)\n\n\nReturns <:FactorData\n\n\n\n\n\n","category":"function"},{"location":"summary/#NavAbilitySDK._getSolverDataDict-Tuple{String, String}","page":"Index","title":"NavAbilitySDK._getSolverDataDict","text":"Internal utility function to create the correct solver data (variable data) given a variable type.\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.addVariable-Tuple{Any, Any, Union{AbstractString, Symbol}, Union{AbstractString, Symbol}}","page":"Index","title":"NavAbilitySDK.addVariable","text":"addVariable Add a variable to the NavAbility Platform service Example\n\naddVariable(client, context, \"x0\", NVA.Pose2)\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.createDownloadEvent-Tuple{NavAbilityClient, AbstractString, Base.UUID}","page":"Index","title":"NavAbilitySDK.createDownloadEvent","text":"createDownloadEvent(navAbilityClient, userId, fileId)\n\n\nRequest URLs for data blob download.\n\nArgs:   navAbilityClient (NavAbilityClient): The NavAbility client.   userId (String): The userId with access to the data.   fileId (String): The unique file identifier of the data blob.\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.createUploadEvent","page":"Index","title":"NavAbilitySDK.createUploadEvent","text":"createUploadEvent(navAbilityClient, filename, filesize)\ncreateUploadEvent(\n    navAbilityClient,\n    filename,\n    filesize,\n    parts\n)\n\n\nRequest URLs for data blob upload.\n\nArgs:   navAbilityClient (NavAbilityClient): The NavAbility client.   filename (String): file/blob name.   filesize (Int): total number of bytes to upload.    parts (Int): Split upload into multiple blob parts, FIXME currently only supports parts=1.\n\n\n\n\n\n","category":"function"},{"location":"summary/#NavAbilitySDK.getStatusLatestEvent-Tuple{NavAbilityClient, String}","page":"Index","title":"NavAbilitySDK.getStatusLatestEvent","text":"getStatusLatestEvent(navAbilityClient, id)\n\n\nGet the latest status message for a request.\n\nArgs:     navAbilityClient (NavAbilityClient): The NavAbility client.     id (String): The ID of the request that you want the latest status on.\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.getStatusMessagesEvent-Tuple{NavAbilityClient, String}","page":"Index","title":"NavAbilitySDK.getStatusMessagesEvent","text":"getStatusMessagesEvent(navAbilityClient, id)\n\n\nGet all the statuses for a request.\n\nArgs:     navAbilityClient (NavAbilityClient): The NavAbility client.     id (String): The ID of the request that you want the statuses on.\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.getStatusesLatest-Tuple{NavAbilityClient, Vector{String}}","page":"Index","title":"NavAbilitySDK.getStatusesLatest","text":"getStatusesLatest(navAbilityClient, ids)\n\n\nHelper function to get a dictionary of all latest statues for a list of results.\n\nArgs:     navAbilityClient (NavAbilityClient): The NavAbility client.     ids (Vector{String}): A list of the IDS that you want statuses on.\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.incrDataLabelSuffix-Tuple{NavAbilityClient, Client, Any, AbstractString}","page":"Index","title":"NavAbilitySDK.incrDataLabelSuffix","text":"incrDataLabelSuffix\n\nIf the blob label thisisme already exists, then this function will return the name thisisme_1. If the blob label thisisme_1 already exists, then this function will return the name thisisme_2.\n\nDO NOT EXPORT, Duplicate functionality from DistributedFactorGraphs.jl.\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.natural_lt-Union{Tuple{T}, Tuple{T, T}} where T<:AbstractString","page":"Index","title":"NavAbilitySDK.natural_lt","text":"natural_lt(x, y)\n\n\nNatural less than for sorting, \n\njulia sort([\"x10\"; \"x1\", \"x11\"]; lt=NavAbilitySDK.natural_lt)`\n\nNotes\n\nduplicated from DFG, hence don't export\n\n\n\n\n\n","category":"method"},{"location":"summary/#NavAbilitySDK.waitForCompletion-Tuple{NavAbilityClient, AbstractVector{<:AbstractString}}","page":"Index","title":"NavAbilitySDK.waitForCompletion","text":"waitForCompletion(\n    navAbilityClient,\n    requestIds;\n    maxSeconds,\n    expectedStatuses,\n    exceptionMessage\n)\n\n\nWait for the requests to complete, poll until done.\n\nArgs:     requestIds (List[str]): The request IDs that should be polled.     maxSeconds (int, optional): Maximum wait time. Defaults to 60.     expectedStatus (str, optional): Expected status message per request.         Defaults to \"Complete\".\n\n\n\n\n\n","category":"method"}]
}
