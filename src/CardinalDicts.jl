module CardinalDicts

export CardinalDict,
       keymax, clearindex!

include("for_indexing.jl")
include("CardinalDict.jl")
include("dict_api_lite.jl")

end # module
