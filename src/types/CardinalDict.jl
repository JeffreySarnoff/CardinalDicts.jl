struct CardinalDict{V,K} <: AbstractCardinalDictionary{V,K}

    present::BitArray{1}    # does this key hold content
    content::Vector{V}      # the keyed content (onlyif present)

    idxmax::K

    function CardinalDict(::Type{V}, maxidx::K) where {K<:Signed, V}
        present = falses(maxidx)
        content = Vector{V}(maxidx)
        T = type_for_indexing(maxidx) 
        idxmax = T(maxidx)
        return new{V,T}(present, content, idxmax)
    end
end

function CardinalDict{V}(maxidx::K) where {K<:Signed, V}
   return CardinalDict(V, maxidx)
end

function CardinalDict(values::A) where A<:AbstractArray{T,1} where T
    n = length(values)
    dict = CardinalDict{T}(n)
    for (idx,val) in enumerate(values)
        dict[idx] = val
    end
    return dict
end
