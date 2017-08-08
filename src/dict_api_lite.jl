# core

Base.length(dict::CardinalDict{K, V}) where {K,V} = sum(dict.valued)
Base.endof(dict::CardinalDict{K,V}) where {K,V} = findlast(dict.valued, true)
Base.isempty(dict::CardinalDict{K, V}) where {K,V} = !any(dict.valued)

Base.eltype(dict::CardinalDict{K, V}) where {K,V} = Pair{K,V}

Base.:(==)(a_dict::D, b_dict::D) where D<:CardinalDict{K,V} where {K,V} =
    keys(a_dict) == keys(b_dict) && values(a_dict) == values(b_dict)
Base.:(==)(a_dict::CardinalDict{K,V}, b_dict::CardinalDict{J,W}) where {J,W,K,V} =
    false

Base.:(!=)(a_dict::D, b_dict::D) where D<:CardinalDict{K,V} where {K,V} =
    keys(a_dict) != keys(b_dict) || values(a_dict) != values(b_dict)
Base.:(!=)(a_dict::CardinalDict{K,V}, b_dict::CardinalDict{J,W}) where {J,W,K,V} =
    true

# get

function Base.get(dict::CardinalDict{K,V}, key::K, default::V) where {K,V}
    return haskey(dict, key) ? getindex(dict.values, key) : default
end
@inline Base.get(dict::CardinalDict{K,V}, key::J, default::V) where {J,K,V} =
    get(dict, key%K, default)

function Base.get!(dict::CardinalDict{K,V}, key::K, default::V) where {K,V}
    if haskey(dict, key)
        getindex(dict.values, key)
    else
        setindex!(dict, default, key)
        default
    end
end
@inline Base.get!(dict::CardinalDict{K,V}, key::J, default::V) where {J,K,V} =
    get!(dict, key%K, default)

# keys, values, in (∈, ∋, ∉, ∌)

function Base.keys(dict::CardinalDict{K,V}) where {K,V}
    allkeys = one(K):keymax(dict)
    result = Vector{K}()
    for k in allkeys
        if haskey(dict, k)
            push!(result,k)
        end
    end
    return result
end

function Base.values(dict::CardinalDict{K,V}) where {K,V} 
    result = Vector{V}()
    for i in keys(dict)
        push!(result, getindex(dict, i))
    end
    return result
end

function Base.in(value::V, dict::CardinalDict{K,V}) where {K,V} 
    return length(dict)!=0 && in(value, values(dict))
end

#@inline Base.:(∈)(value::V, dict::CardinalDict{K,V}) where {K,V} = in(value, dict) # not needed
@inline Base.:(∋)(dict::CardinalDict{K,V}, value::V) where {K,V} = in(value, dict)
@inline Base.:(∉)(value::V, dict::CardinalDict{K,V}) where {K,V} = !in(value, dict)
@inline Base.:(∌)(dict::CardinalDict{K,V}, value::V) where {K,V} = !in(value, dict)

# delete!, clearindex!, empty!

function Base.delete!(dict::CardinalDict{K,V}, key::K) where {K,V}
    0 < key <= keymax(dict) || throw(ErrorException("Key (index) $(key) is outside of the domain 1:$(keymax(dict))."))
    @inbounds setindex!(dict.valued, false, key)
    return dict
end
@inline Base.delete!(dict::CardinalDict{K,V}, key::J) where {J,K,V} =
    delete!(dict, key%K)

function Base.empty!(dict::CardinalDict{K,V}) where {K,V}
    0 < key <= keymax(dict) || throw(ErrorException("Key (index) $(key) is outside of the domain 1:$(keymax(dict))."))
    for k in keys(dict)
        @inbounds setindex!(dict.valued, false, key)
    end    
    return dict
end


# iteration

function Base.start(dict::CardinalDict{K,V}) where {K,V}
    (1, keys(dict)) 
end

function Base.next(dict::CardinalDict{K,V}, state) where {K,V}
    index, ks = state
    (ks[index], dict.values[index]), (index+1, ks)
end

function Base.done(dict::CardinalDict{K,V}, state) where {K,V}
    state[1] > length(dict)
end
