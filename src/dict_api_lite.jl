# core
Base.length(dict::CardinalDict{K, V}) where {K,V} = sum(dict.valued)
Base.endof(dict::CardinalDict{K,V}) where {K,V} = length(dict.valued)

Base.eltype(dict::CardinalDict{K, V}) where {K,V} = Pair{K,V}

Base.:(==)(a_dict::D, b_dict::D) where D<:CardinalDict{K,V} where {K,V} =
    a_dict.values == b_dict.values
Base.:(==)(a_dict::CardinalDict{K,V}, b_dict::CardinalDict{J,W}) where {J,W,K,V} =
    false

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

# keys, values

@inline keymax(dict::CardinalDict{K,V}) where {K,V} = length(dict.valued)%K

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

# string, io

function Base.string(dict::CardinalDict{K,V}) where {K,V}
    length(dict) == 0 && return string("CardinalDict{",K,",",V,"}()")
    ks = keys(dict)
    vs = values(dict)
    kv = [Pair(k,v) for (k,v) in zip(ks,vs)]
    return string("CardinalDict{",K,",",V,"}(",kv,")")
end

function Base.show(io::IO, dict::CardinalDict{K,V}) where {K,V}
    print(io, string(dict))
end
