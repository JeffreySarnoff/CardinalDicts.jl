@inline function check_index(dict::CardinalDict{V,K}, idx::K) where {K<:Signed, V}
    return one(K) <= idx <= dict.idxmax
end
@inline function check_index(dict::CardinalDict{V,K}, idx::J) where {J<:Signed,K,V}
    return check_index(dict, idx%K)
end

@inline function guarded_index(dict::CardinalDict{V,K}, idx::K) where {K<:Signed, V}
    check_index(dict, idx) || throw(ErrorException("invalid index ($(idx))"))
    return nothing
end
@inline function guarded_index(dict::CardinalDict{V,K}, idx::J) where {J<:Signed,K,V}
    return guarded_index(dict, idx%K)
end     

@inline function check_present(dict::CardinalDict{V,K}, idx::K) where {K<:Signed, V}
    return getindex(dict.present, idx)
end
@inline function check_present(dict::CardinalDict{V,K}, idx::J) where {J<:Signed,K,V}
    return check_present(dict, idx%K)
end

@inline function guarded_present(dict::CardinalDict{V,K}, idx::K) where {K<:Signed, V}
    check_present(dict, idx) || throw(ErrorException("there is no content at index ($(idx))"))
    return nothing
end
@inline function guarded_present(dict::CardinalDict{V,K}, idx::J) where {J<:Signed,K,V}
    return guarded_present(dict, idx%K)
end

@inline function keyval(dict::CardinalDict{V,K}, idx::K) where {K<:Signed, V}
    guarded_index(dict, idx)
    return idx
end
@inline function keyval(dict::CardinalDict{V,K}, idx::J) where {J<:Signed,K,V}
    return keyval(dict, idx%K)
end

@inline function unsafe_keyval(dict::CardinalDict{V,K}, idx::K) where {K<:Signed, V}
    return idx
end
@inline function unsafe_keyval(dict::CardinalDict{V,K}, idx::J) where {J<:Signed,K,V}
    return idx%K
end

# some essential Julia associative, dict API functions

function Base.haskey(dict::CardinalDict{V,K}, idx::K) where {K<:Signed, V}
    guarded_index(dict, idx)
    return check_present(dict, idx)
end
@inline function Base.haskey(dict::CardinalDict{V,K}, idx::J) where {J<:Signed, K<:Signed, V}
    return haskey(dict, idx%K)
end

# this is quite unsafe
function unsafe_haskey(dict::CardinalDict{V,K}, idx::K) where {K<:Signed, V}
    return check_present(dict, idx)
end
@inline function unsafe_haskey(dict::CardinalDict{V,K}, idx::J) where {J<:Signed, K<:Signed, V}
    return unsafe_haskey(dict, idx%K)
end

function Base.getindex(dict::CardinalDict{V,K}, idx::K) where {K<:Signed, V}
    guarded_index(dict, idx)
    guarded_present(dict, idx)
    return getindex(dict.content, idx)
end
@inline function Base.getindex(dict::CardinalDict{V,K}, idx::J) where {J<:Signed, K<:Signed, V}
    return getindex(dict, idx%K)
end

function unsafe_getindex(dict::CardinalDict{V,K}, idx::K) where {K<:Signed, V}
    guarded_present(dict, idx)
    return getindex(dict.content, idx)
end
@inline function unsafe_getindex(dict::CardinalDict{V,K}, idx::J) where {J<:Signed, K<:Signed, V}
    return unsafe_getindex(dict, idx%K)
end

function Base.get(dict::CardinalDict{V,K}, idx::K, default::V) where {K<:Signed, V}
    guarded_index(dict, idx)
    return check_present(dict, idx) ? getindex(dict.content, idx) : default
end
@inline function Base.get(dict::CardinalDict{V,K}, idx::J, default::V) where {J<:Signed, K<:Signed, V}
    return get(dict, idx%K, default)
end

function Base.get!(dict::CardinalDict{V,K}, idx::K, default::V) where {K<:Signed, V}
    guarded_index(dict, idx)
    result = default
    if check_present(dict, idx)
       result = getindex(dict, idx)
    else
       setindex!(dict, default, idx)
    end      
    return result
end
@inline function Base.get!(dict::CardinalDict{V,K}, idx::J, default::V) where {J<:Signed, K<:Signed, V}
    return get!(dict, idx%K, default)
end

function Base.setindex!(dict::CardinalDict{V,K}, value::V, idx::K) where {K<:Signed, V}
     guarded_index(dict, idx)
     setindex!(dict.present, true, idx)
     setindex!(dict.content, value, idx)
     return value
end
@inline function Base.setindex!(dict::CardinalDict{V,K}, value::V, idx::J) where {J<:Signed, K<:Signed, V}
    return setindex!(dict, value, idx%K)
end

function unsafe_setindex!(dict::CardinalDict{V,K}, value::V, idx::K) where {K<:Signed, V}
     setindex!(dict.present, true, idx)
     setindex!(dict.content, value, idx)
     return value
end
@inline function unsafe_setindex!(dict::CardinalDict{V,K}, value::V, idx::J) where {J<:Signed, K<:Signed, V}
    return unsafe_setindex!(dict, value, idx%K)
end
