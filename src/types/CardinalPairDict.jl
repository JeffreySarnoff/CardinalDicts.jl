struct CardinalPairDict{V,K} <: AbstractCardinalDictionary{V,K}

    present::BitArray{1}    # does this key hold content
    content::Vector{V}      # the keyed content (onlyif present)

    idx1max::K
    idx2max::K

    function CardinalPairDict(::Type{V}, idx1max::K, idx2max::K) where {K<:Signed, V}
        n = pair(idx1max, idx2max)
        present = falses(n)
        content = Vector{V}(n)
        T = type_for_indexing(n) 
        idxmax = T(n)
        return new{V,T}(present, content, T(idx1max), T(idx2max))
    end
end

function CardinalPairDict{V}(idx1max::K, idx2max::K) where {K<:Signed, V}
   return CardinalPairDict(V, idx1max, idx2max)
end

function CardinalPairDict{V}(idx12max::K) where {K<:Signed, V}
   return CardinalPairDict(V, idx12max, idx12max)
end

function CardinalPairDict(values::A) where A<:AbstractArray{T,2} where T
    nrows, ncols = size(values)
    dict = CardinalPairDict{T}(nrows, ncols)
    for r in 1:nrows
        for c in 1:ncols
            dict[r,c] = values[r,c]
        end
    end
    return dict
end
