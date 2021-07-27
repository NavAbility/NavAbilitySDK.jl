module Queries

gql_list(query_name::String, type::String;regexFilter::Union{Nothing, Regex}=nothing,
    tags::Vector{Symbol}=Symbol[], 
    solvable::Int=0) = """
    query $query_name(\$userId: ID!, \$robotId: ID!, \$sessionId: ID!) {
      $type(filter: {
            session: {
              id: \$sessionId, 
              robot: {
                id: \$robotId, 
                user: {
                  id: \$userId
                }}}, 
            $(tags != [] ? "tags_contains: [\"" * join(String.(tags), "\", \"") * "\"]," : "")
            $(regexFilter !== nothing ? "label_regexp: \""*regexFilter.pattern*"\"," : "")
            $(solvable > 0 ? "solvable_gte: "*string(solvable) : "")
            }) {
        label
      }
    }
"""

gql_ls(;regexFilter::Union{Nothing, Regex}=nothing,
    tags::Vector{Symbol}=Symbol[], 
    solvable::Int=0) = gql_list("ls", "VARIABLE", regexFilter=regexFilter, tags=tags, solvable=solvable)

gql_lsf(;regexFilter::Union{Nothing, Regex}=nothing,
    tags::Vector{Symbol}=Symbol[], 
    solvable::Int=0) = gql_list("lsf", "FACTOR", regexFilter=regexFilter, tags=tags, solvable=solvable)

end