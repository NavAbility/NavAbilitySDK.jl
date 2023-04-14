using TOML

function matchfragments(str::String)
    frag_regex = r"\.{3}(?<fragment>[a-zA-Z_]*)[ \n\r]" #...FRAGMENT_NAME 
    return map(x->x[:fragment], eachmatch(frag_regex, str))
end

"""
Function to find all fragments in `operation::String` with 1 level of nesting in found fragments
"""
function fragmentnames(gql_dict::Dict, operation::String)
    fragment_names = matchfragments(gql_dict["operations"][operation])
    nested_names = mapreduce(x->matchfragments(gql_dict["fragments"][x]), union, fragment_names)
    return union(nested_names, fragment_names)
end

function getGQL(gql_dict::Dict, operation::String)
    fragments = mapreduce(x->gql_dict["fragments"][x], *, fragmentnames(gql_dict, operation))
    return fragments*gql_dict["operations"][operation]
end

##

tomlfiles = filter(endswith(".toml"), readdir(@__DIR__()))

gql_dict = mapreduce(TOML.parsefile, mergewith(merge), tomlfiles)

operation = "MUTATION_ADD_VARIABLES"

fragmentnames(gql_dict, operation)

print(getGQL(gql_dict, operation))