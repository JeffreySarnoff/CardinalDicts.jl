__precompile__()

module CardinalDicts
pr
export  AbstractCardinalDict,
        CardinalDict, CardinalPair, Cardinal\DictPair
        clearindex!, keymax, is_full

@abstract type AbstractCardinalDict{K,V} <: Associative{K,V} end

struct CardinalDict{K,V} <: AbstractCardinalDict{K,V}

    first_index::K    #  lowest  index, currently nonempty
    final_index::K    #  highest index, currently nonempty
    index_start::K    #  smallest admissible index
    index_endof::K    #  largest  admissible index

    guards_gate::BitVector   #  associable bistable states
    keeps_value::Vector{V}   #  indexable stores of value

    function CardinalDict{V}(items_max::K) where {K,V}
        
        T = type_for_indexing(items_max)
        
        index_start, index_endof = one(T), T(items_max)
        first_index, final_index = zero(T), zero(T) 

        guards_gate = falses(items_max)
        keeps_value = Vector{V}(items_max)
        
        return new{T,V}(first_index, final_index,
                        index_start, index_endof, 
                        guards_gate, keeps_value)
    end
end

# Allow items_max to be given as a 1-Tuple (10_000,);
# this provides multidim sizes a consistent interface.

function CardinalDict{V}( items_max::NTuple{1,K}) where {K,V}
    return CardinalDict{V}( items_max )
end



struct CardinalPairDict{K,V} <: AbstractCardinalDict{K,V}

                       #  the xs of (x,y)
    first_index1::K    #  lowest  index, currently nonempty
    final_index1::K    #  highest index, currently nonempty
    index1_start::K    #  smallest admissible index
    index1_endof::K    #  largest  admissible index

                       #  the ys of (x,y)
    first_index2::K    #  lowest  index, currently nonempty
    final_index2::K    #  highest index, currently nonempty
    index2_start::K    #  smallest admissible index
    index2_endof::K    #  largest  admissible index

    guards_gate::BitVector   #  associable bistable states
    keeps_value::Vector{V}   #  indexable stores of value

    function CardinalPairDict{V}(dim_sizes::NTuple{2,K}) where {K,V}
        
        size1, size2 = dim_sizes
        items_max = size1 * size2        
        T = type_for_indexing(items_max)
        
        index_start1, index_endof1 = one(T), T(size1)
        index_start2, index_endof2 = one(T), T(size2)
        
        first_index1, final_index1 = zero(T), zero(T) 
        first_index2, final_index2 = zero(T), zero(T) 

        guards_gate = falses(items_max)
        keeps_value = Vector{V}(items_max)
        
        return new{T,V}(first_index1, final_index1,
                        index1_start, index1_endof, 
                        first_index2, final_index2,
                        index2_start, index2_endof, 
                        guards_gate,  keeps_value)
    end
end

function CardinalDict{V}(size::NTuple{2,K}) where {K,V}
    return CardinalDict{V}( (size[1], size[2]) )
end

struct CardinalPairDict{K,V} <: AbstractCardinalDict{K,V}

    index_start::K        #  smallest admissible index
    index_endof::K        #  largest  admissible index

    first_index::K        #  lowest  currently nonempty index
    final_index::K        #  highest currently nonempty index

    gatesway::BitVector   #  associable bistable states
    keepsval::Vector{V}   #  indexable stores of value

    function CardinalPairDict{V}(maxentries::K) where {K,V}
        
        T = type_for_indexing(maxentries)
        index_start, index_endof = one(T), T(maxentries)
        first_index, final_index = zero(T), zero(T) 

        gates_theway = falses(maxentries)
        keeps_theval = Vector{V}(maxentries)
        
        return new{T,V}(index_start,  index_endof,
                        first_index,  final_index,
                        gates_theway, keeps_theval)
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
