include("NBitSets.jl")
using .NBitSets

struct IndexedDict{N, K, V} <: Associative{K,V}
    valued::NBitSet{N}
    values::Vector{V}
    
    function IndexedDict{V1}(n::N1) where N1<:Integer where V1
        valued = NBitSet{n}
        values = Vector{V1}(n)
        return new{N1,N1,V1}(valued, values)
    end
end

@inline function Base.haskey(dict::IndexedDict{N,K,V}, key::K) where V where K<:Integer where N
   getindex(dict.valued, key)
end

function Base.getindex(dict::IndexedDict{N,K,V}, key::K) where V where K<:Integer where N
    haskey(dict, key) && return dict[key]
    throw(ErrorException("Key (index) $(key) has not been given a value"))
end

function Base.setindex!(dict::IndexedDict{N,,K,V}, value::V, key::K) where V where K<:Integer where N
    0 < key <= N || throw(ErrorException("Key (index) $(key) is outside of the domain 1:$(N)."))
    dict.values[key] = value
    return dict
end

        
