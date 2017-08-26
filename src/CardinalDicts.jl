__precompile__()

module CardinalDicts

export  AbstractCardinalDict,
        CardinalDict, CardinalPair, Cardinal\DictPair
        clearindex!, keymax, is_full
--
@abstract type AbstractCardinalDict{K,V} <: Associative{K,V} end

struct CardinalDict{K,V} <: AbstractCardinalDict{K,V}

    index_start::K    # smallest admissible index
    index_endof::K    # largest  admissible index

    first_index::K    # lowest  index that is nonempty
    final_index::K    # highest index that is nonempty

    valued::BitArray{1}
    values::Vector{V}

    function CardinalDict{V}(maxentries::K) where {K,V}
        T = type_for_indexing(maxentries)
        indexmax = T(maxentries)

        valued = falses(n)
        values = Vector{V}(n)
        
        return new{T,V}(indexmax, valued, values)
    end
end



struct CardinalPairDict{K,V} <: AbstractCardinalDict{K,V}
    idxmax::NTuple{2,K}

    valued::BitArray{1}
    values::Vector{V}

    function CardinalPairDict{V}(maxidx::K) where {K,V}
        T = Tuple{K}
        n = T(maxidx)

        valued = falses(n)
        values = Vector{V}(n)
        return new{T,V}(idxmax, valued, values)
    end
end


struct CardinalDictPair <: AbstractCardinalDict{K,V}
    idxmax::Tuple{K}

    valued::BitArray{1}
    values::Vector{V}

    function CardinalDictPair{V}(maxidx::K) where {K,V}
        T = type_for_indexing(maxidx)
        n = T(maxidx)

        valued = falses(n)
        values = Vector{V}(n)
        return new{T,V}(idxmax, valued, values)
    end
end

include("indicable.jl")

V

struct CardinalPairDict{K,V} <: AbstractCardinalDict{K,V}
    idx1max::K
    idx2max::K

    valued::BitArray{1}
    values::Vector{V}

    function CardinalDictPair{V}(maxidx1::K, maxidx2::K) where

     {K<:Signed where V

        maxidx = maxidx1 * maxidx2
        T = type_for_indexing(maxidx)
        n = T(maxidx)

        valued = falses(n)
        values = Vector{V}(n)
        return new{T,V}(idx1max, idx2max, valued, values)
    end
end

struct CardinalDictPairs{K,V} <: AbstractCardinalDict{K<:Signed,V}
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


include("cardinalkeys.jl")

include("CardinalDict.jl")
include("CardinalDict_api.jl")

end # module
