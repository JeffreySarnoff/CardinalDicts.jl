# core
Base.length(dict::CardinalDict{K, V}) where {K,V} = sum(dict.valued)
Base.endof(dict::CardinalDict{K,V}) where {K,V} = findlast(dict.valued, true)
Base.isempty(dict::CardinalDict{K, V}) where {K,V} = !any(dict.valued)

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

# string, io

function Base.string(dict::CardinalDict{K,V}) where {K,V}
    length(dict) == 0 && return string("CardinalDict{",K,",",V,"}()")
    vs = values(dict)
    return string("CardinalDict(",vs,")")
end

function Base.show(io::IO,dict::CardinalDict{K,V}) where {K,V}
    n = length(dict)
    n == 0 && return string("CardinalDict{",K,",",V,"}()")
    ks = keys(dict)
    vs = values(dict)
    ttyrows = displaysize(Base.TTY())[1] - 2
    if ttyrows >= n  
        kv = [Pair(k,v) for (k,v) in zip(ks,vs)]
        str = string("CardinalDict(",kv,")")
    else
        if ttyrows >= n
            kv = [Pair(k,v) for (k,v) in zip(ks,vs)]
            str = string("CardinalDict(",kv,")")
        else
            ttyrows = fld(ttyrows-2, 2)
            kvfront = [Pair(k,v) for (k,v) in zip(ks[1:ttyrows], vs[1:ttyrows])]
            kvback  = [Pair(k,v) for (k,v) in zip(ks[end-ttyrows:end], vs[end-ttyrows:end])]
            sfront = string(kvfront)
            sback  = string(kvback)
        str = string(sfront[findfirst(sfront,'}')+1:end-1],",  ...\n  ", sback[findfirst(sback,'}')+2:end])
            str = string("CardinalDict(", str, ")")
            str = join(split(str,", "),",\n  ")
        end
    end
    return print(io, str)
end

