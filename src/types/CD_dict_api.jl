# core

Base.length(dict::CardinalDict{V,K}) where {K,V} = sum(dict.present)
Base.endof(dict::CardinalDict{V,K}) where {K,V} = findlast(dict.present, true)
Base.isempty(dict::CardinalDict{V,K}) where {K,V} = sum(dict.present) == 0
isfull(dict::CardinalDict{V,K}) where {K,V} = all(dict.present)

Base.eltype(dict::CardinalDict{V,K}) where {K,V} = Pair{K,V}

Base.:(==)(a_dict::D, b_dict::D) where D<:CardinalDict{V,K} where {K,V} =
    keymax(a_dict) == keymax(b_dict) && keys(a_dict) == keys(b_dict) && content(a_dict) == content(b_dict)
Base.:(==)(a_dict::CardinalDict{V,K}, b_dict::CardinalDict{J,W}) where {J,W,K,V} =
    false

Base.:(!=)(a_dict::D, b_dict::D) where D<:CardinalDict{V,K} where {K,V} =
    keymax(a_dict) != keymax(b_dict)  || keys(a_dict) != keys(b_dict) || content(a_dict) != content(b_dict)
Base.:(!=)(a_dict::CardinalDict{V,K}, b_dict::CardinalDict{J,W}) where {J,W,K,V} =
    true

# keys, content, in (∈, ∋, ∉, ∌)

function tally_active(dict::CardinalDict{V,K}) where {K,V}
    return sum(dict.present)
end
function tally_passive(dict::CardinalDict{V,K}) where {K,V}
    return length(dict.present) - sum(dict.present)
end

function Base.keys(dict::CardinalDict{V,K}) where {K,V}
    result = Vector{K}(tally_active(dict))
    allkeys = one(K):keymax(dict)
    result[:] = allkeys[dict.present]
    return result
end

function Base.values(dict::CardinalDict{V,K}) where {K,V}
    result = Vector{V}(tally_active(dict))
    allkeys = keys(dict)
    for (i,ky) in enumerate(allkeys)
        result[i] = getindex(dict, ky)
    end
    return result
end

function Base.in(value::V, dict::CardinalDict{V,K}) where {K,V}
    return length(dict)!=0 && in(value, content(dict))
end

#@inline Base.:(∈)(value::V, dict::CardinalDict{V,K}) where {K,V} = in(value, dict) # not needed
@inline Base.:(∋)(dict::CardinalDict{V,K}, value::V) where {K,V} = in(value, dict)
@inline Base.:(∉)(value::V, dict::CardinalDict{V,K}) where {K,V} = !in(value, dict)
@inline Base.:(∌)(dict::CardinalDict{V,K}, value::V) where {K,V} = !in(value, dict)

# delete!, clearindex!, empty!

function Base.delete!(dict::CardinalDict{V,K}, key::K) where {K,V}
    check_index(dict, key)
    setindex!(dict.present, false, key)
    return dict
end
@inline Base.delete!(dict::CardinalDict{V,K}, key::J) where {J,K,V} =
    delete!(dict, key%K)

function Base.empty!(dict::CardinalDict{V,K}) where {K,V}
    0 < key <= keymax(dict) || throw(ErrorException("Key (index) $(key) is outside of the domain 1:$(keymax(dict))."))
    dict.present[:] = falses(length(dict.present))
    return dict
end

# iteration

function Base.start(dict::CardinalDict{V,K}) where {K,V}
    (1, keys(dict))
end

function Base.next(dict::CardinalDict{V,K}, state) where {K,V}
    index, ks = state
    (ks[index], dict.present[index]), (index+1, ks)
end

function Base.done(dict::CardinalDict{V,K}, state) where {K,V}
    state[1] > length(dict)
end


# nonstandard

keymax(dict::CardinalDict{V,K}) where {K,V} = K(length(dict.content))

function clearindex!(dict::CardinalDict{V,K}, key::K) where K where V
    check_index(dict, key)
     @inbounds setindex!(dict.present, false, key)
    return nothing
end
@inline clearindex!(dict::CardinalDict{V,K}, key::J) where J where K where V =
    clearindex!(dict, key%K)
