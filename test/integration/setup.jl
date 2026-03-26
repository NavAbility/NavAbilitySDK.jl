# Shared test setup for integration tests
# Creates a client, agent, and graph that subsequent test files use.

using LieGroups
using LieGroups: TranslationGroup

# ---------------------------------------------------------------------------
# Define test variable and factor types (following DFG testBlocks.jl pattern)
# ---------------------------------------------------------------------------
DFG.@defStateType TestPosition1 TranslationGroup(1) [0.0;]
DFG.@defStateTypeN TestPosition{N} TranslationGroup(N) zeros(N)
const TestPosition2 = TestPosition{2}

DFG.@defObservationType TestRelative1 RelativeObservation TranslationGroup(1)
DFG.@defObservationType TestPrior1 PriorObservation TranslationGroup(1)

@kwdef struct TestBelief
    a::Float64 = 1.0
    b::Float64 = 3.0
end

TestRelative1() = TestRelative1(TestBelief())
TestPrior1() = TestPrior1(TestBelief())

# ---------------------------------------------------------------------------
# Environment and client setup
# ---------------------------------------------------------------------------
AUTH_TOKEN = ENV["AUTH_TOKEN"]
API_URL = get(ENV, "API_URL", "https://api.navability.io/graphql")
TEST_AGENT_LABEL = Symbol("TestAgent_", randstring(4))
TEST_GRAPH_LABEL = Symbol("TestGraph_", randstring(4))

# Create the client
client = NavAbilityClient(AUTH_TOKEN, API_URL)

# call show to make sure there is no errors in the function
show(stdout, MIME"text/plain"(), client)

# Create the main fgclient used by most tests (agent + graph created automatically)
fgclient = NavAbilityDFG(
    client,
    TEST_GRAPH_LABEL,
    TEST_AGENT_LABEL;
    addAgentIfAbsent = true,
    addGraphIfAbsent = true,
)

# call show to make sure there is no errors in the function
show(stdout, MIME"text/plain"(), fgclient)

@info "Test setup complete" agent = TEST_AGENT_LABEL graph = TEST_GRAPH_LABEL
