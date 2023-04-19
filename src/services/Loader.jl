using TOML
using FilePathsBase
using FileIO
using Glob
using GraphQLClient  # used to parse GraphQL queries
# import GraphQLClient as GQL # used to parse GraphQL queries

# Define a struct to represent a GraphQL fragment with a name and data
struct Fragment
    name::String
    data::String
    dependent_fragments::Vector{Fragment}
end

function generateDependencies(fragment::Fragment, all_fragments::Dict{String, Fragment})::Vector{Fragment}
    # Pattern for any fragment starting with an ellipsis
    pattern = r"\.{3}[a-zA-Z_]*[ \n\r]"
    dependent_fragment_names = [match[3:end-1] for match in eachmatch(pattern, fragment.data)]
    for d in dependent_fragment_names
        if get(all_fragments, d, nothing) === nothing
            throw(ErrorException("Query $(fragment.name) uses fragment $d and this fragment does not exist."))
        end
    end
    fragment.dependent_fragments = [all_fragments[d] for d in dependent_fragment_names]
    return fragment.dependent_fragments
end

function getFragmentName(fragment::Fragment)::Union{String, Nothing}
    pattern = r"fragment\s+(\S+)\s+on"
    match = match(pattern, fragment.data)
    if match !== nothing
        return match[1]
    else
        return nothing
    end
end

function Base.show(io::IO, f::Fragment)
    print(io, "$(f.name):\n", join(f.data, "\n"))
end

# Define a struct to represent a GraphQL operation (query, mutation, or subscription) with a type and data
struct Operation
    operation_type::String
    data::String
end

function Base.show(io::IO, o::Operation)
    print(io, "$(o.operation_type):\n$(o.data)")
end

# Define a function to get all files with a given extension from a given folder path
function getFiles(folder_path::AbstractString, extension::AbstractString)::Vector{String}
    files = FilePath[]
    for file in readdir(folder_path)
        file_path = joinpath(folder_path, file)
        if isdir(file_path)
            append!(files, get_files(file_path, extension))
        elseif endswith(file, extension)
            push!(files, file_path)
        end
    end
    return files
end

# Define a function to read all TOML files in a given folder path and return a tuple of a dictionary of fragment names mapped to their corresponding Fragment objects and a dictionary of operation names mapped to their corresponding Operation objects
function getOperations(folder_path::AbstractString)::Tuple{Dict{String, Fragment}, Dict{String, Operation}}
    files = getFiles(folder_path, ".toml")

    fragments = Dict{String, Fragment}()
    operations = Dict{String, Operation}()

    # Load all fragments
    for file in files
        data = TOML.parsefile(file)

        # Extract and store all fragments from the TOML file
        for (name, frag_string) in get(data, "fragments", Dict())
            fragment = Fragment(name, frag_string, Fragment[])
            fragments[name] = fragment
        end
    end

    # Flatten all dependencies
    for fragment in values(fragments)
        generateDependencies(fragment, fragments)
    end

    function detectCycle(fragment::Fragment, visited::Set{Fragment}, path::Vector{Fragment})::Bool
        push!(visited, fragment)
        push!(path, fragment)

        for dep in fragment.dependent_fragments
            if !(dep in visited)
                if detectCycle(dep, visited, path)
                    return true
                end
            elseif dep in path
                println("Warning: Cyclic reference detected in fragments: ", join([f.name for f in path], ", "))
                return true
            end
        end

        pop!(path)
        return false
    end

    visited = Set{Fragment}()
    for fragment in values(fragments)
        if !(fragment in visited)
            detect_cycle(fragment, visited, Fragment[])
        end
    end

    # Replace all fragment recursion if any exist (expecting "...")
    while any([length(f.dependent_fragments) > 0 for f in values(fragments)])
        # Go through the list until done.
        for fragment in values(fragments)
            if length(fragment.dependent_fragments) > 0  # Else ignore.
                # If all parents have been resolved, resolve it.
                if all([length(f.dependent_fragments) == 0 for f in fragment.dependent_fragments])
                    fragment.data = join([df.data for df in fragment.dependent_fragments], "\r\n") * "\r\n" * fragment.data
                    # Clear it
                    fragment.dependent_fragments = Fragment[]
                end
            end
        end
    end

    # Load all operations and include all fragments
    for file in files
        data = TOML.parsefile(file)

        # Extract and store all operations from the TOML file
        for (name, operation_data) in get(data, "operations", Dict())
            operation = Operation("", operation_data)

            # Include any fragments at the bottom of the query if they are used in the query
            for (fd_name, fragment) in fragments
                if fd_name in operation_data
                    operation.data *= "\n\n" * fragment.data
                end
            end

            try
                # Parse the operation data using the gql function and set the operation type
                #operation.data = ?
                #operation.operation_type = ?
                operations[name] = operation
            catch e
                if isa(e, GraphQLClient.GraphQLError)
                    # If there is an error parsing the operation data, print an error message
                    println("Error: Error parsing operation data: $e \n $(operation.data)")
                else
                    rethrow(e)
                end
            end
        end
    end

    return (fragments, operations)
end

# Load all GraphQL operations from the "sdkCommonGQL" folder and export them
#GQL_FRAGMENTS, GQL_OPERATIONS = getOperations( ? )