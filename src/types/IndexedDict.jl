struct IndexedDict{K,V} <: Associative{K,V}
    valued::BitArray{1}
    values::Vector{V}
    
    function IndexedDict{V}(n::K) where K<:Integer where V
        valued = falses(n)
        values = Vector{V}(n)
        return new{K,V}(valued, values)
    end
end

@inline function Base.haskey(dict::IndexedDict{K,V}, key::K) where K where V
   return getindex(dict.valued, key)
end

function Base.getindex(dict::IndexedDict{K,V}, key::K) where K where V
    haskey(dict, key) && return dict[key]
    throw(ErrorException("Key (index) $(key) has not been given a value"))
end

function Base.get(dict::IndexedDict{K,V}, key::K, default::V) where K where V
    return haskey(dict, key) ? dict[key] : default
end

function Base.setindex!(dict::IndexedDict{K,V}, value::V, key::K) where K where V
    0 < key <= length(dict) || throw(ErrorException("Key (index) $(key) is outside of the domain 1:$(length(dict))."))
    dict.valued[key] = true
    dict.values[key] = value
    return dict
end

        
