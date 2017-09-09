@inline function check_index(dict::CardinalPairDict{V,K}, idx1::K, idx2::K) where {K<:Signed, V}
    return (one(K) <= idx1 <= dict.idx1max) && (one(K) <= idx2 <= dict.idx2max)
end
@inline function check_index(dict::CardinalPairDict{V,K}, idx1::J, idx2::J) where {J<:Signed,K,V}
    return check_index(dict, idx1%K, idx2%K)
end

@inline function guarded_index(dict::CardinalPairDict{V,K}, idx1::K, idx2::K) where {K<:Signed, V}
    check_index(dict, idx1, idx2) || throw(ErrorException("invalid index ($(idx1), $(idx2))"))
    return nothing
end
@inline function guarded_index(dict::CardinalPairDict{V,K}, idx1::J, idx2::J) where {J<:Signed,K,V}
    return guarded_index(dict, idx1%K, idx2%K)
end     

@inline function check_present(dict::CardinalPairDict{V,K}, idx1::K, idx2::K) where {K<:Signed, V}
    return getindex(dict.present, pair(idx1, idx2))
end
@inline function check_present(dict::CardinalPairDict{V,K}, idx1::J, idx2::J) where {J<:Signed,K,V}
    return check_present(dict, idx1%K, idx2%K)
end
@inline function check_present(dict::CardinalPairDict{V,K}, paired::K) where {K<:Signed, V}
    return getindex(dict.present, paired)
end

@inline function guarded_present(dict::CardinalPairDict{V,K}, idx1::K, idx2::K) where {K<:Signed, V}
    check_present(dict, idx1, idx2) || throw(ErrorException("there is no content at index ($(idx1), $(idx2))"))
    return nothing
end
@inline function guarded_present(dict::CardinalPairDict{V,K}, idx1::J, idx2::J) where {J<:Signed,K,V}
    return guarded_present(dict, idx1%K, idx2%K)
end

@inline function guarded_present(dict::CardinalPairDict{V,K}, paired::K) where {K<:Signed, V}
    if !check_present(dict, paired)
        idx1, idx2 = unpair(paired)
        throw(ErrorException("there is no content at index ($(idx1), $(idx2))"))
    end
    return nothing
end

@inline function keyval(dict::CardinalPairDict{V,K}, idx1::K, idx2::K) where {K<:Signed, V}
    guarded_index(dict, idx1, idx2)
    return pair(idx1, idx2)
end
@inline function keyval(dict::CardinalPairDict{V,K}, idx1::J, idx2::J) where {J<:Signed,K,V}
    return keyval(dict, idx1%K, idx2%K)
end

@inline function unsafe_keyval(dict::CardinalPairDict{V,K}, idx1::K, idx2::K) where {K<:Signed, V}
    return pair(idx1, idx2)
end
@inline function unsafe_keyval(dict::CardinalPairDict{V,K}, idx1::J, idx2::J) where {J<:Signed,K,V}
    return idx1%K, idx2%K
end

# some essential Julia associative, dict API functions

function Base.haskey(dict::CardinalPairDict{V,K}, idx1::K, idx2::K) where {K<:Signed, V}
    guarded_index(dict, idx1, idx2)
    return check_present(dict, idx1, idx2)
end
@inline function Base.haskey(dict::CardinalPairDict{V,K}, idx1::J, idx2::J) where {J<:Signed, K<:Signed, V}
    return haskey(dict, idx1%K, idx2%K)
end
@inline function Base.haskey(dict::CardinalPairDict{V,K}, idx12::Tuple{K,K}) where {K<:Signed, V}
    return haskey(dict, idx12[1], idx12[2])
end
@inline function Base.haskey(dict::CardinalPairDict{V,K}, idx12::Tuple{J,J}) where {J<:Signed, K<:Signed, V}
    return haskey(dict, idx12[1]%K, idx12[2]%K)
end

# this is quite unsafe
function unsafe_haskey(dict::CardinalPairDict{V,K}, idx1::K, idx2::K) where {K<:Signed, V}
    return check_present(dict, idx1, idx2)
end
@inline function unsafe_haskey(dict::CardinalPairDict{V,K}, idx1::J, idx2::J) where {J<:Signed, K<:Signed, V}
    return unsafe_haskey(dict, idx1%K, idx2%K)
end
function unsafe_haskey(dict::CardinalPairDict{V,K}, paired::K) where {K<:Signed, V}
    return check_present(dict, paired)
end

function Base.getindex(dict::CardinalPairDict{V,K}, idx1::K, idx2::K) where {K<:Signed, V}
    guarded_index(dict, idx1, idx2)
    paired = pair(idx1, idx2)
    guarded_present(dict, paired)
    return getindex(dict.content, paired)
end
@inline function Base.getindex(dict::CardinalPairDict{V,K}, idx1::J, idx2::J) where {J<:Signed, K<:Signed, V}
    return getindex(dict, idx1%K, idx2%K)
end
@inline function Base.getindex(dict::CardinalPairDict{V,K}, idx12::Tuple{K,K}) where {K<:Signed, V}
    return getindex(dict, idx12[1], idx12[2])
end
@inline function Base.getindex(dict::CardinalPairDict{V,K}, idx12::Tuple{J,J}) where {J<:Signed, K<:Signed, V}
    return getindex(dict, idx12[1]%K, idx12[2]%K)
end

function unsafe_getindex(dict::CardinalPairDict{V,K}, idx1::K, idx2::K) where {K<:Signed, V}
    paired = pair(idx1, idx2)
    guarded_present(dict, idx1, idx2)
    return getindex(dict.content, idx1, idx2)
end
@inline function unsafe_getindex(dict::CardinalPairDict{V,K}, idx1::J, idx2::J) where {J<:Signed, K<:Signed, V}
    return unsafe_getindex(dict, idx1%K, idx2%K)
end

function Base.get(dict::CardinalPairDict{V,K}, idx1::K, idx2::K, default::V) where {K<:Signed, V}
    guarded_index(dict, idx1, idx2)
    return check_present(dict, idx1, idx2) ? getindex(dict.content, idx1, idx2) : default
end
@inline function Base.get(dict::CardinalPairDict{V,K}, idx1::J, idx2::J, default::V) where {J<:Signed, K<:Signed, V}
    return get(dict, idx1%K, idx2%K, default)
end
@inline function Base.get(dict::CardinalPairDict{V,K}, idx12::Tuple{K,K}, default::V) where {K<:Signed, V}
    return get(dict, idx12[1], idx12[2], default)
end
@inline function Base.get(dict::CardinalPairDict{V,K}, idx12::Tuple{J,J}, default::V) where {J<:Signed, K<:Signed, V}
    return get(dict, idx12[1]%K, idx12[2]%K, default)
end

function Base.get!(dict::CardinalPairDict{V,K}, idx1::K, idx2::K, default::V) where {K<:Signed, V}
    guarded_index(dict, idx1, idx2)
    result = default
    if check_present(dict, idx1, idx2)
       result = getindex(dict, idx1, idx2)
    else
       setindex!(dict, default, idx1, idx2)
    end      
    return result
end
@inline function Base.get!(dict::CardinalPairDict{V,K}, idx1::J, idx2::J, default::V) where {J<:Signed, K<:Signed, V}
    return get!(dict, idx%K, idx2%K, default)
end
@inline function Base.get!(dict::CardinalPairDict{V,K}, idx12::Tuple{K,K}, default::V) where {K<:Signed, V}
    return get!(dict, idx12[1], idx12[2], default)
end
@inline function Base.get!(dict::CardinalPairDict{V,K}, idx12::Tuple{J,J}, default::V) where {J<:Signed, K<:Signed, V}
    return get!(dict, idx12[1]%K, idx12[2]%K, default)
end

function Base.setindex!(dict::CardinalPairDict{V,K}, value::V, idx1::K, idx2::K) where {K<:Signed, V}
     guarded_index(dict, idx1, idx2)
     paired = pair(idx1, idx2)
     setindex!(dict.present, true, paired)
     setindex!(dict.content, value, paired)
     return value
end
@inline function Base.setindex!(dict::CardinalPairDict{V,K}, value::V, idx1::J, idx2::J) where {J<:Signed, K<:Signed, V}
    return setindex!(dict, value, idx1%K, idx2%K)
end
@inline function Base.setindex!(dict::CardinalPairDict{V,K}, value::V, idx12::Tuple{K,K}) where {K<:Signed, V}
    return setindex!(dict, value, idx12[1], idx12[2])
end
@inline function Base.setindex!(dict::CardinalPairDict{V,K}, value::V, idx12::Tuple{J,J}) where {J<:Signed, K<:Signed, V}
    return setindex!(dict, value, idx12[1]%K, idx12[2]%K)
end

function unsafe_setindex!(dict::CardinalPairDict{V,K}, value::V, idx1::K, idx2::K) where {K<:Signed, V}
     paired = pair(idx1, idx2)
     setindex!(dict.present, true, paired)
     setindex!(dict.content, value, paired)
     return value
end
@inline function unsafe_setindex!(dict::CardinalPairDict{V,K}, value::V, idx1::J, idx2::J) where {J<:Signed, K<:Signed, V}
    return unsafe_setindex!(dict, value, idx1%K, idx2%K)
end
