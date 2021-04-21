module Queries

gql_ls(regexFilter::Union{Nothing, Regex}=nothing; 
    tags::Vector{Symbol}=Symbol[], 
    solvable::Int=0) = """
    query ls($userId: ID!, $robotId: ID!, $sessionId: ID!) {
      VARIABLE(filter: {
            session: {
              id: $sessionId, 
              robot: {
                id: $robotId, 
                user: {
                  id: $userId
                }}}, 
            $(tags != [] ? "tags_contains: [\"" * join(String.(tags), "\", \"") * "\"]," : "")
            $(regexFilter !== nothing ? "label_regexp: \""*regexFilter*"\"," : "")
            $(solvable > 0 ? "solvable_gte: "*solvable : "")
            }) {
        label
      }
    }
"""

end