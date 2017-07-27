include("NBitSets.jl")
using .NBitSets

struct IndexedDict{N, K, V} <: Associative{K,V}
    valued::NBitSet{N}
    values::Vector{V}
    
    function IndexedDict{V1}(n::N1) where N1<:Integer where V1
        n16 = n%Int16
        valued = NBitSet{n16}
        values = Vector{V1}(n16)
        return new{Int16,eltype(valued),V1}(valued, values)
    end
end

@inline function Base.haskey(dict::IndexedDict{N,K,V}, key::K) where V where K<:Integer where N
   getindex(dict.valued, key%Int16)
end

function Base.getindex(dict::IndexedDict{N,K,V}, key::K) where V where K<:Integer where N
    cle = key%Int16
    haskey(dict, cle) && return dict[cle]
    throw(ErrorException("Key (index) $(key) has not been given a value"))
end

function Base.setindex!(dict::IndexedDict{N,K,V}, value::V, key::K) where V where K<:Integer where N
    0 < key <= N || throw(ErrorException("Key (index) $(key) is outside of the domain 1:$(N)."))
    dict.values[key%Int16] = value
    return dict
end

        
