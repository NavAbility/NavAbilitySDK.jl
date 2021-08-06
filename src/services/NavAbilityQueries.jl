module Queries

## Fields: Variables 
fieldsVariable() = """
    label
    timestamp {formatted}
    variableType
    smallData
    solvable
    tags
    _version
    _id
    ppes {
      solveKey
      suggested
      max
      mean
      lastUpdatedTimestamp {formatted}
    }
    solverData 
    {
      solveKey
      BayesNetOutVertIDs
      BayesNetVertID
      dimIDs
      dimbw
      dims
      dimval
      dontmargin
      eliminated
      inferdim
      initialized
      ismargin
      separator
      solveInProgress
      solvedCount
      variableType
      vecbw
      vecval
      _version
    }
"""

fieldsVariableSummary() = """
    label
    timestamp {formatted}
    tags
    ppes {
      solveKey
      suggested
      max
      mean
      lastUpdatedTimestamp {formatted}
    }
    variableType
    _version
    _id
"""

fieldsVariableSkeleton() = """
    label
    tags
"""

## Fields: Factors

fieldsFactor() = """
    label
    timestamp {formatted}
    fnctype
    tags
    solvable
    data
    _variableOrderSymbols
    _version
"""

fieldsFactorSummary() = """
    label
    timestamp {formatted}
    tags
    _variableOrderSymbols
    _version
"""

fieldsFactorSkeleton() = """
    label
    tags
    _variableOrderSymbols
"""

## Queries

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


gql_getVariables(label::String = ""; regexFilter::Union{Nothing, Regex}=nothing,
    tags::Vector{Symbol}=Symbol[], 
    solvable::Int=0,
    fields=fieldsVariable()) = """
  query getVariables(\$userId: ID!, \$robotId: ID!, \$sessionId: ID!) {
    VARIABLE(filter: {
          $(label != "" ? "label: \"$label\"," : "")
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
          }) 
    {
$fields
    }
  }
"""

gql_getFactors(label::String=""; regexFilter::Union{Nothing, Regex}=nothing,
    tags::Vector{Symbol}=Symbol[], 
    solvable::Int=0,
    fields=fieldsFactor()) = """
  query getFactors(\$userId: ID!, \$robotId: ID!, \$sessionId: ID!) {
    FACTOR(filter: {
      $(label != "" ? "label: \"$label\"," : "")
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
        }) 
    {
$fields
    }
  }
"""

end