__precompile__()

module CardinalDicts

export AbstractCardinalDictionary, 
       CardinalDict, CardinalPairDict,
       keymax, keysmax, clearindex!, isfull

# the order of the params is reversed so constructors work more cleanly
abstract type AbstractCardinalDictionary{V,K} <: Associative{K,V} end

include("support/pairing.jl")
include("support/typedindexing.jl")

include("types/CardinalDict.jl")
include("types/CD_indexed_api.jl")
include("types/CD_dict_api.jl")
include("types/CD_string_show.jl")

include("types/CardinalPairDict.jl")
include("types/CPD_indexed_api.jl")
include("types/CPD_dict_api.jl")
include("types/CPD_string_show.jl")

end # module
