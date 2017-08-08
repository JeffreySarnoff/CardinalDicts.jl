__precompile__()

module CardinalDicts

export CardinalDict, clearindex!, keymax, isfull

include("for_indexing.jl")
include("CardinalDict.jl")
include("CardinalDict_api.jl")

end # module
