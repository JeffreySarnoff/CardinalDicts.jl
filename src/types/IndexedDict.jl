include("NBitSets.jl")

struct IndexedDict{N, K<:Integer, V} <: Associative{K,V} where V where K where N
    valued::NBitSet{N}
    values::Vector{V}
    
    function IndexedDict{V}(N) where N<:Integer
        valued = NBitSet{N}
        values = Vector{V}(N)
        return new{N,typeof(N),V}(valued, values)
    end
end
