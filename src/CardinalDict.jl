struct CardinalDict{K,V} <: Associative{K,V}
    valued::BitArray{1}
    values::Vector{V}
    
    function CardinalDict{V}(n::K) where K<:Integer where V
        valued = falses(n)
        values = Vector{V}(n)
        T = type_for_indexing(n)
        return new{T,V}(valued, values)
    end
end

function CardinalDict(values::Vector{T}) where T
    n = length(values)
    dict = CardinalDict{T}(n)
    for i in 1:n
        @inbounds dict[i] = values[i]
    end
    return dict
end

const SInt = Union{Int8, Int16, Int32, Int64, Int128}

# these two support eval(parse(string(dict::CardinalDict)))

function CardinalDict(zipped::Base.Iterators.Zip2{Array{I,1},Array{V,1}}; maxkey::SInt=length(zipped)) where {I<:SInt,V}
    thekeys = map(first, zipped)
    thevals = map(last, zipped)
    maxkey  = max(maxkey, maximum(thekeys))
    result = CardinalDict{V}(maxkey)
    for (k,v) in zipped
        result[k] = v
    end
    return result
end

function CardinalDict(pairs::Vector{Pair{I,V}}) where {I<:SInt,V}
    thekeys = map(first, pairs)
    thevals = map(last, pairs)
    maxkey  = maximum(thekeys)
    result = CardinalDict{V}(maxkey)
    for (k,v) in zip(thekeys, thevalues)
        result[k] = v
    end
    return result    
    return CardinalDict( zip(thekeys, thevals) )
end


# direct manipulations

@inline function Base.haskey(dict::CardinalDict{K,V}, key::K) where {K,V}
   return getindex(dict.valued, key)
end
@inline Base.haskey(dict::CardinalDict{K,V}, key::J) where {J,K,V} =
    haskey(dict, key%K)

function Base.getindex(dict::CardinalDict{K,V}, key::K) where {K,V}
    haskey(dict, key) || throw(ErrorException("Key (index) $(key) has not been given a value"))
    @inbounds return getindex(dict.values, key)
end
@inline Base.getindex(dict::CardinalDict{K,V}, key::J) where {J,K,V} =
    getindex(dict, key%K)

function Base.setindex!(dict::CardinalDict{K,V}, value::V, key::K) where {K,V}
    0 < key <= keymax(dict) || throw(ErrorException("Key (index) $(key) is outside of the domain 1:$(keymax(dict))."))
    @inbounds begin
        setindex!(dict.valued, true, key)
        setindex!(dict.values, value, key)
    end
    return dict
end
@inline Base.setindex!(dict::CardinalDict{K,V}, value::V, key::J) where J where K where V =
    setindex!(dict, value, key%K)
