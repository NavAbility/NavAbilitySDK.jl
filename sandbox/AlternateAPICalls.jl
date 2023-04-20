GQL_GET_VARIABLE2 = """
$(GQL_FRAGMENT_VARIABLES)
query get_variables(
    \$userLabel: String!
    \$robotLabel: String!
    \$sessionLabel: String!
    \$variableLabel: String!
    \$fields_summary: Boolean! = true
    \$fields_full: Boolean! = true
  ) {
    variables(
      where: {
        userLabel: \$userLabel
        robotLabel: \$robotLabel
        sessionLabel: \$sessionLabel
        label: \$variableLabel
      }
    ) {
      ...variable_skeleton_fields
      ...variable_summary_fields @include(if: \$fields_summary)
      ...variable_full_fields @include(if: \$fields_full)
    }
  }
"""

GQL_GET_VARIABLES2 = """
$(GQL_FRAGMENT_VARIABLES)
query get_variables(
  \$userLabel: String!
  \$robotLabel: String!
  \$sessionLabel: String!
  \$fields_summary: Boolean! = true
  \$fields_full: Boolean! = true
) {
  variables(
    where: {
      userLabel: \$userLabel
      robotLabel: \$robotLabel
      sessionLabel: \$sessionLabel
    }
  ) {
    ...variable_skeleton_fields
    ...variable_summary_fields @include(if: \$fields_summary)
    ...variable_full_fields @include(if: \$fields_full)
  }
}
"""

function getVariable2(fgclient::DFGClient, label::Symbol)
    variables = Dict(
        "userLabel" => fgclient.user.label,
        "robotLabel" => fgclient.robot.label,
        "sessionLabel" => fgclient.session.label,
        "variableLabel" => string(label),
        "fields_summary" => true,
        "fields_full" => true,
    )

    response = GQL.execute(
        fgclient.client,
        GQL_GET_VARIABLE2,
        Vector{Variable};
        variables,
        throw_on_execution_error = true,
    )
    return response.data["variables"][1]
end

function getVariablesSkeleton2(fgclient::DFGClient)#, label::Symbol)
    variables = Dict(
        "userLabel" => fgclient.user.label,
        "robotLabel" => fgclient.robot.label,
        "sessionLabel" => fgclient.session.label,
        "fields_summary" => false,
        "fields_full" => false,
    )

    response = GQL.execute(
        fgclient.client,
        GQL_GET_VARIABLES2,
        Vector{DFG.SkeletonDFGVariable};
        variables,
        throw_on_execution_error = true,
    )
    return response.data["variables"]
end
