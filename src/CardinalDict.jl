function CardinalDict(values::Vector{T}) where T
    n = length(values)
    dict = CardinalDict{T}(n)
    for i in 1:n
        @inbounds dict[i] = values[i]
    end
    return dict
end

function CardinalPairDict(values1::Vector{T}, values2::Vector{T}) where T
    n1 = length(values1)
    n2 = length(values2)
    n = n1*n2
    dict = CardinalPairDict{T}(n1, n2)
    for i1 in 1:n1
        for i2 in 1:n2
            @inbounds dict[i] = values[i]
    end
    return dict
end

const SInt = Union{Int8, Int16, Int32, Int64, Int128}

# these two support eval(parse(string(dict::CardinalDict)))

function CardinalDict(zipped::Base.Iterators.Zip2{Array{I,1},Array{V,1}}, maxkey::SInt=length(zipped)) where {I<:SInt,V}
    thekeys = map(first, zipped)
    thevals = map(last, zipped)
    maxkey  = max(maxkey, maximum(thekeys))
    result = CardinalDict{V}(maxkey)
    for (k,v) in zipped
        result[k] = v
    end
    return result
end

function CardinalDict(pairs::Vector{Pair{I,V}}, maxkey::SInt=length(pairs)) where {I<:SInt,V}
    thekeys = map(first, pairs)
    thevals = map(last, pairs)
    maxkey  = max(maxkey, maximum(thekeys))
    result = CardinalDict{V}(maxkey)
    for (k,v) in zip(thekeys, thevals)
        result[k] = v
    end
    return result
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
