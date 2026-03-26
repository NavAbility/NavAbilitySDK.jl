module GraphQLRegistries

# Path to the versioned registry
const REGISTRY_PATH = joinpath(@__DIR__, "v0.6")

# Storage for the fully-stitched GraphQL strings
# Access via: GraphQLRegistry.GQL_OPS[:addNodes]
const GQL_OPS = Dict{Symbol, String}()

"""
    resolve_fragments(text::String, resolved_names::Set{String})

Recursively identifies fragment spreads (e.g. ...VariableFields_fields) and 
prepends the corresponding file from the flat 'fragments/' directory.
"""
function resolve_fragments(text::String, resolved_names::Set{String} = Set{String}())
    # Regex captures the exact string after the three dots
    # Matches: ...VariableFields_fields -> Group 1: VariableFields_fields
    matches = eachmatch(r"\.\.\.([a-zA-Z0-9_]+)", text)
    fragment_names = unique([m.captures[1] for m in matches])
    
    stitched_text = ""
    
    for fname in fragment_names
        if !(fname in resolved_names)
            push!(resolved_names, fname)
            
            # Perfect Match: fragment Name -> fragments/Name.graphql
            frag_path = joinpath(REGISTRY_PATH, "fragments", "$fname.graphql")
            
            if isfile(frag_path)
                frag_content = read(frag_path, String)
                
                # RECURSION: Check if this fragment depends on other fragments
                nested_deps = resolve_fragments(frag_content, resolved_names)
                
                # Definitions must precede usage in the final string
                stitched_text *= nested_deps * "\n" * frag_content * "\n"
            else
                error("Fragment file not found: $frag_path. Ensure the spread '...$fname' matches the filename exactly.")
            end
        end
    end
    return stitched_text
end

"""
    load_gql_from_path(full_path::String)

Reads a raw operation file and returns a single string with all 
required fragments prepended.
"""
function load_gql_from_path(full_path::String)
    raw_content = read(full_path, String)
    stitched_fragments = resolve_fragments(raw_content)
    
    return strip(stitched_fragments * "\n" * raw_content)
end

"""
    init_registry!()

Recursively walks through 'queries/' and 'mutations/' folders to find 
every .graphql file and populates GQL_OPS.
"""
function init_registry!()
    empty!(GQL_OPS)
    
    for root_dir in ["queries", "mutations"]
        start_path = joinpath(REGISTRY_PATH, root_dir)
        !isdir(start_path) && continue
        
        # walkdir handles any level of entity nesting (e.g., mutations/Variable/...)
        for (root, dirs, files) in walkdir(start_path)
            for file in files
                endswith(file, ".graphql") || continue
                
                # key is the filename without extension: addVariables.graphql -> :addVariables
                base_name = replace(file, ".graphql" => "")
                full_path = joinpath(root, file)
                
                content = load_gql_from_path(full_path)
                GQL_OPS[Symbol(base_name)] = content
            end
        end
    end
    return GQL_OPS
end

# Automatically initialize the registry when the module is loaded
init_registry!()
__init__() = init_registry!()

end # module