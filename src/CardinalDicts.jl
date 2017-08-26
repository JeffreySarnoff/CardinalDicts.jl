__precompile__()

module CardinalDicts

export AbstractCardinalDict, CardinalDict, CardinalPairDict

abstract type AbstractCardinalDict{K,V} <: Associative{K,V} end

abstract type AbstractCardinal{K}()   #  highest index, currently nonempty
    index_start::K    #  smallest admissible index  (jgh)
    index_endof::K    #  largest  admissible index  (ugg)
 
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

function CardinalPairDict{V}(size::NTuple{2,K}) where {K,V}
    return CardinalPairDict{V}( (size[1], size[2]) )
end



include("cardinalkeys.jl")

include("CardinalDict.jl")
include("CardinalDict_api.jl")

end # module
