# core

Base.length(dict::CardinalPairDict{V,K}) where {K,V} = sum(dict.present)
Base.endof(dict::CardinalPairDict{V,K}) where {K,V} = findlast(dict.present, true)
Base.isempty(dict::CardinalPairDict{V,K}) where {K,V} = !any(dict.present)
isfull(dict::CardinalPairDict{V,K}) where {K,V} = all(dict.present)

Base.eltype(dict::CardinalPairDict{V,K}) where {K,V} = Pair{K,V}

Base.:(==)(a_dict::D, b_dict::D) where D<:CardinalPairDict{V,K} where {K,V} =
    keymax(a_dict) == keymax(b_dict) && keys(a_dict) == keys(b_dict) && content(a_dict) == content(b_dict)
Base.:(==)(a_dict::CardinalPairDict{V,K}, b_dict::CardinalPairDict{J,W}) where {J,W,K,V} =
    false

Base.:(!=)(a_dict::D, b_dict::D) where D<:CardinalPairDict{V,K} where {K,V} =
    keymax(a_dict) != keymax(b_dict)  || keys(a_dict) != keys(b_dict) || content(a_dict) != content(b_dict)
Base.:(!=)(a_dict::CardinalPairDict{V,K}, b_dict::CardinalPairDict{J,W}) where {J,W,K,V} =
    true

# keys, content, in (∈, ∋, ∉, ∌)

function tally_active(dict::CardinalPairDict{V,K}) where {K,V}
    return sum(dict.present)
end
function tally_passive(dict::CardinalPairDict{V,K}) where {K,V}
    return length(dict.present) - sum(dict.present)
end

function internal_keys(dict::CardinalPairDict{V,K}) where {K,V}
    allkeys = one(K):keymax(dict)
    result = Vector{K}()
    for k in allkeys
        if unsafe_haskey(dict, k)
            push!(result,k)
        end
    end
    return result
end

function Base.keys(dict::CardinalPairDict{V,K}) where {K,V}
   allkeys = internal_keys(dict)
   result = Vector{Tuple{K,K}}()
   for k in allkeys
        push!(result, unpair(k))
   end
   return result
end

function Base.values(dict::CardinalPairDict{V,K}) where {K,V}
    allkeys = keys(dict)
    result = Vector{V}()
    for (x,y) in allkeys
        push!(result, getindex(dict, x, y))
    end
    return result
end

function Base.in(value::V, dict::CardinalPairDict{V,K}) where {K,V}
    return length(dict)!=0 && in(value, content(dict))
end

#@inline Base.:(∈)(value::V, dict::CardinalPairDict{V,K}) where {K,V} = in(value, dict) # not needed
@inline Base.:(∋)(dict::CardinalPairDict{V,K}, value::V) where {K,V} = in(value, dict)
@inline Base.:(∉)(value::V, dict::CardinalPairDict{V,K}) where {K,V} = !in(value, dict)
@inline Base.:(∌)(dict::CardinalPairDict{V,K}, value::V) where {K,V} = !in(value, dict)

# delete!, clearindex!, empty!


function Base.delete!(dict::CardinalPairDict{V,K}, key1::K, key2::K) where {K,V}
    check_index(dict, key1, key2)
    key = pair(key1, key2)
    @inbounds setindex!(dict.present, false, key)
    return dict
end
@inline function Base.delete!(dict::CardinalPairDict{V,K}, keys::Tuple{K,K}) where {K,V}
    return delete!(dict, keys...)
end
@inline Base.delete!(dict::CardinalPairDict{V,K}, key1::J, key2::J) where {J,K,V} =
    delete!(dict, key1%K, key2%K)
@inline Base.delete!(dict::CardinalPairDict{V,K}, keys::Tuple{J,J}) where {J,K,V} =
    delete!(dict, keys[1]%K, keys[2]%K)

function Base.delete!(dict::CardinalPairDict{V,K}, key::K) where {K,V}
    0 < key <= keymax(dict) || throw(ErrorException("Key (index) $(key) is outside of the domain 1:$(keymax(dict))."))
    @inbounds setindex!(dict.present, false, key)
    return dict
end
@inline Base.delete!(dict::CardinalPairDict{V,K}, key::J) where {J,K,V} =
    delete!(dict, key%K)

function Base.empty!(dict::CardinalPairDict{V,K}) where {K,V}
    0 < key <= keymax(dict) || throw(ErrorException("Key (index) $(key) is outside of the domain 1:$(keymax(dict))."))
    for k in keys(dict)
        @inbounds setindex!(dict.present, false, key)
    end
    return dict
end

# iteration

function Base.start(dict::CardinalPairDict{V,K}) where {K,V}
    (1, keys(dict))
end

function Base.next(dict::CardinalPairDict{V,K}, state) where {K,V}
    index, ks = state
    (ks[index], dict.present[index]), (index+1, ks)
end

function Base.done(dict::CardinalPairDict{V,K}, state) where {K,V}
    state[1] > length(dict)
end

# nonstandard

keymax(dict::CardinalPairDict{V,K}) where {K,V} = K(length(dict.present))
keyamax(dict::CardinalPairDict{V,K}) where {K,V} = unpair(K(length(dict.present)))

function clearindex!(dict::CardinalPairDict{V,K}, key1::K, key2::K) where {K,V}
    check_index(dict, key1, key2)
    key = pair(key1, key2)
    @inbounds setindex!(dict.present, false, key)
    return nothing
end
@inline function clearindex!(dict::CardinalPairDict{V,K}, keys::Tuple{K,K}) where {K,V}
    return clearindex!(dict, keys...)
end
@inline clearindex!(dict::CardinalPairDict{V,K}, key1::J, key2::J) where {J,K,V} =
    clearindex!(dict, key1%K, key2%K)
@inline clearindex!(dict::CardinalPairDict{V,K}, keys::Tuple{J,J}) where {J,K,V} =
    clearindex!(dict, keys[1]%K, keys[2]%K)
