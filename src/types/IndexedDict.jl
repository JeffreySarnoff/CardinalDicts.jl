include("NBitSets.jl")
using .NBitSets

struct IndexedDict{K,V} <: Associative{K,V}
    valued::NBitSet{K}
    values::Vector{V}
    
    function IndexedDict{V}(n::K) where K<:Integer where V
        valued = NBitSet(n)
        values = Vector{V}(n)
        if V<:Number
           values[:] = zero(V)
        elseif V<:String
           values[:] = ""
        else
           values[:] = convert(V, 0)
         end
        return new{K,V}(valued, values)
    end
end

@inline function Base.haskey(dict::IndexedDict{K,V}, key::K) where K where V
   getindex(dict.valued, key)
end

function Base.getindex(dict::IndexedDict{K,V}, key::K) where K where V
    haskey(dict, key) && return dict[key]
    throw(ErrorException("Key (index) $(key) has not been given a value"))
end

function Base.get(dict::IndexedDict{K,V}, key::K, default::V) where K where V
    return haskey(dict, key) ? dict[key] : default
end

function Base.get(dict::IndexedDict{K,V}, key::K, default::S) where K where V where S
    return haskey(dict, key) ? dict[key] : convert(V,default)
end

function Base.setindex!(dict::IndexedDict{K,V}, value::V, key::K) where K where V
    0 < key <= length(dict) || throw(ErrorException("Key (index) $(key) is outside of the domain 1:$(length(dict))."))
    dict.values[key] = value
    return dict
end

        
