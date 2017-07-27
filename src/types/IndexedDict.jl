include("NBitSets.jl")
using .NBitSets

struct IndexedDict{N, K, V} <: Associative{K,V} where V where K where N
    valued::NBitSet{N}
    values::Vector{V}
    
    function IndexedDict{V}(N) where N<:Integer
        valued = NBitSet{N}
        values = Vector{V}(N)
        return new{N,typeof(N),V}(valued, values)
    end
end

@inline function Base.haskey(dict::IndexedDict{N,,K,V}, key::K) where V where K<:Integer where N
   getindex(dict.valued, key)
end

function Base.getindex(dict::IndexedDict{N,,K,V}, key::K) where V where K<:Integer where N
    haskey(dict, key) && return dict[key]
    throw(ErrorException("Key (index) $(key) has not been given a value"))
end

function Base.setindex!(dict::IndexedDict{N,,K,V}, value::V, key::K) where V where K<:Integer where N
    0 < key <= N || throw(ErrorException("Key (index) $(key) is outside of the domain 1:$(N)."))
    dict.values[key] = value
    return dict
end

        
