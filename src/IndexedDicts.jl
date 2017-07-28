module IndexedDicts

export IndexedDictonary,
       clearindex!

include("for_indexing.jl")
include("IndexedDict.jl")
include("dict_api_lite.jl")

end # module
