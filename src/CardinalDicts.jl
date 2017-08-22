__precompile__()

module CardinalDicts

export  AbstractCardinalDict,
        CardinalDict, 
        clearindex!, keymax, isfull

abstract type AbstractCardinalDict{K<:Signed,V} <: Associative{K,V} end

include("for_indexing.jl")

struct CardinalDict{K,V} <: AbstractCardinalDict{K<:Signed,V}
    idxmax::K

    valued::BitArray{1}
    values::Vector{V}
    
    function CardinalDict{V}(n::K) where K<:Integer where V
        valued = falses(n)
        values = Vector{V}(n)
        T = type_for_indexing(n)
        idxmax = T(n)
        return new{T,V}(idxmax, valued, values)
    end
end

struct CardinalPairDict{K,V} <: AbstractCardinalDict{K<:Signed,V}
    idx1max::K
    idx2max::K

    valued::BitArray{1}
    values::Vector{V}
    
    function CardinalPairDict{V}(maxidx1::K, maxidx2::K) where K<:Signed where V
        n = maxidx1 * maxidx2
        valued = falses(n)
        values = Vector{V}(n)
        T = type_for_indexing(n)
        idx1max = T(maxidx1)
        idx2max = T(maxidx2)
        return new{T,V}(idx1max, idx2max, valued, values)
    end
end

@inline function check_index(dict::CardinalDict{K,V}, idx::K) where {K,V}
     return one(K) <= idx <= dict.idxmax
end
@inline function check_index(dict::CardinalDict{K,V}, idx::J) where {J<:Signed,K,V}
     return check_index(dict, idx%K)
end
@inline function check_index(dict::CardinalPairDict{K,V}, idx1::K, idx2::K) where {K,V}
     return (one(K) <= idx1 <= dict.idx1max) && (one(K) <= idx2 <= dict.idx2max) 
end
@inline function check_index(dict::CardinalPairDict{K,V}, idx1::J, idx2::J) where {J<:Signed,K,V}
     return check_index(dict, idx1%K, idx2%K)
end

@inline function guarded_index(dict::CardinalDict{K,V}, idx::K) where {K,V}
     check_index(dict, idx) || throw(ErrorException("invalid index ($(idx))"))
end
@inline function guarded_index(dict::CardinalDict{K,V}, idx::J) where {J<:Signed,K,V}
     check_index(dict, idx) || throw(ErrorException("invalid index ($(idx))"))
end
@inline function guarded_index(dict::CardinalPairDict{K,V}, idx1::K, idx2::K) where {K,V}
     check_index(dict, idx1, idx2) || throw(ErrorException("invalid index ($(idx1), $(idx2))"))
end
@inline function guarded_index(dict::CardinalPairDict{K,V}, idx1::J, idx2::J) where {J<:Signed,K,V}
     check_index(dict, idx1, idx2) || throw(ErrorException("invalid index ($(idx1), $(idx2))"))
end

  
@inline function keyval(dict::CardinalDict{K,V}, idx::K) where {K,V}
    guarded_index(dict, idx)
    return idx
end
@inline function keyval(dict::CardinalDict{K,V}, idx::J) where {J<:Signed,K,V}
     idx1 = idx%K
     guarded_index(dict, idx1)
     return idx1
end

@inline function keyval(dict::CardinalPairDict{K,V}, idx1::K, idx2::K) where {K,V}
    guarded_index(dict, idx1, idx2)
    return elegantpair(idx1, idx2)
end
@inline function keyval(dict::CardinalPairDict{K,V}, idx1::J, idx2::J) where {J<:Signed,K,V}
     idxone = idx1%K
     idxtwo = idx2%K
     return keyval(dict, idxone, idxtwo)
end

function elegantpair(x::T, y::T) where T<:Signed
    mx = max(x,y)
    mx2 = mx * mx
    mx2 += x+y
    return mx2 - (y===mx ? y : 0)
end

include("CardinalDict.jl")
include("CardinalDict_api.jl")

end # module
