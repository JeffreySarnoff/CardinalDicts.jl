include("NBitSets.jl")
using .NBitSets

struct IndexedDict{K,V} <: Associative{K,V}
    valued::NBitSet{K}
    values::Vector{V}
    
    function IndexedDict{V}(n::K) where K<:Integer where V
        valued = NBitSet(n)
        values = Vector{V}(n)
        return new{K,V}(valued, values)
    end
end

@inline function Base.haskey(dict::IndexedDict{K,V}, key::K) where K<:Integer where V
   getindex(dict.valued, key%Int16)
end

function Base.getindex(dict::IndexedDict{K,V}, key::K) where K<:Integer where V
    haskey(dict, key) && return dict[key]
    throw(ErrorException("Key (index) $(key) has not been given a value"))
end

function Base.setindex!(dict::IndexedDict{K,V}, value::V, key::K) where K<:Integer where V
    0 < key <= N || throw(ErrorException("Key (index) $(key) is outside of the domain 1:$(N)."))
    dict.values[key] = value
    return dict
end

        
