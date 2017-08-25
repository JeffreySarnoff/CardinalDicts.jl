
@inline function check_index(dict::CardinalDict{K,V}, idx::K) where {K,V}
     return one(K) <= idx <= dict.idxmax
end
@inline function check_index(dict::CardinalDict{K,V}, idx::J) where {J<:Signed,K,V}
     return check_index(dict, idx%K)
end
@inline function check_index(dict::CardinalPairDict{K,V}, idx1::K, idx2::K) where {K,V}
     return (one(K) <= idx1 <= dict.idx1max) && (one(K) <= idx2 <= dict.idx2max) 
end
@inline function check_index(dict::CardinalPairDict{K,V}, idx1::J, idx2::J) where {J<:Signed,K,V}
     return check_index(dict, idx1%K, idx2%K)
end

@inline function guarded_index(dict::CardinalDict{K,V}, idx::K) where {K,V}
     check_index(dict, idx) || throw(ErrorException("invalid index ($(idx))"))
end
@inline function guarded_index(dict::CardinalDict{K,V}, idx::J) where {J<:Signed,K,V}
     check_index(dict, idx) || throw(ErrorException("invalid index ($(idx))"))
end
@inline function guarded_index(dict::CardinalPairDict{K,V}, idx1::K, idx2::K) where {K,V}
     check_index(dict, idx1, idx2) || throw(ErrorException("invalid index ($(idx1), $(idx2))"))
end
@inline function guarded_index(dict::CardinalPairDict{K,V}, idx1::J, idx2::J) where {J<:Signed,K,V}
     check_index(dict, idx1, idx2) || throw(ErrorException("invalid index ($(idx1), $(idx2))"))
end

  
@inline function keyval(dict::CardinalDict{K,V}, idx::K) where {K,V}
    guarded_index(dict, idx)
    return idx
end
@inline function keyval(dict::CardinalDict{K,V}, idx::J) where {J<:Signed,K,V}
     idx1 = idx%K
     guarded_index(dict, idx1)
     return idx1
end

@inline function keyval(dict::CardinalPairDict{K,V}, idx1::K, idx2::K) where {K,V}
    guarded_index(dict, idx1, idx2)
    return sqshell(idx1, idx2) # return elegantpair(idx1, idx2)
end
@inline function keyval(dict::CardinalPairDict{K,V}, idx1::J, idx2::J) where {J<:Signed,K,V}
     idxone = idx1%K
     idxtwo = idx2%K
     return keyval(dict, idxone, idxtwo)
end

function sqshell(x::T, y::T) where T<:Signed
    mx = max(x,y) - 1
    y  = y - x + 1
    mx*mx + mx + y
end

# iff false then x>y else x<=y
unsqshelltst(n) = n <= round(Int,sqrt(n-0.5))^2

function unsqshell(z::T) where T<:Signed
    sqrtz = isqrt(z)
    sqrtzp1 = sqrtz + one(T)
    zmsqrtz2= z - sqrtz*sqrtz
    xya = (sqrtzp1, zmsqrtz2)
    xyb = ((2*(sqrtzp1)-(zmsqrtz2)), sqrtzp1)
    if z == sqshell(xya...)
        xya
    elseif z == sqshell(xyb...)
        xyb
    else
        throw(ErrorException("unsqshell not found for ($(z))"))
    end
end

function elegantpair(x::T, y::T) where T<:Signed
    mx = max(x,y)
    mx2 = mx * mx
    mx2 += x+y
    return mx2 - (y===mx ? y : 0)
end

function elegantunpair(z::T) where T<:Signed
    isz  = isqrt(z)
    isz2 = isz*isz
    if (z - isz2) < isz
        x = z-isz2
        y = isz
    else
        x = isz
        y = z - isz2 - isz
        y += y=== 0 ? x : 0
    end
    return x, y
end
