#=
    reference
       http://szudzik.com/ElegantPairing.pdf
               x    .    .    .
           z  : 0 |  1 |  2 | 3   ...
         -----:---|----|----|----
     y     0  : 0 |  2 |  6 | 12 
     .     1  : 1 |  3 |  7 | 13 
     .     2  : 4 |  5 |  8 | 14 
     .     3  : 9 | 10 | 11 | 15 
          ...
    for x,y,z >= 0
    pair(x,y) =
        if x == max(x,y)
            x*x + x + y
        else
            y*y + x
        end
         
    unpair(z) =
        if z - isqrt(z)^2 < isqrt(z)
            (z - isqrt(z)^2, isqrt(z))
        else
            (isqrt(z), z - isqrt(z)^2 - isqrt(z))
        end
=#

const SignedInt   = Union{Int8, Int16, Int32, Int64, Int128}

# elegantpair(pairablemax(T), pairablemax(T)) == pairedmax(T)

pairablemax(::Type{Int128}) = Int128(13_043_817_825_332_782_211)
pairablemax(::Type{Int64})  = Int64(3_037_000_498)
pairablemax(::Type{Int32})  = Int32(46_339)
pairablemax(::Type{Int16})  = Int16(180)
pairablemax(::Type{Int8})   = Int8(10)

pairedmax(::Type{Int128}) = Int128(170_141_183_460_469_231_722_567_801_800_623_612_943)
pairedmax(::Type{Int64})  = Int128(9_223_372_030_926_249_000)
pairedmax(::Type{Int32})  = Int128(2_147_395_599)
pairedmax(::Type{Int16})  = Int128(32_760)
pairedmax(::Type{Int8})   = Int128(120)

function type_for_pair_indexing(xmax::T, ymax::T) where T<:SignedInt
    if min(xmax, ymax) <= zero(T) || (T===Int128 && max(xmax, ymax) > pairablemax(Int128))
         throw(ErrorException("($xmax,$ymax) is outside of domain for paired indexing"))
    end
    
    x = Int128(xmax)
    y = Int128(ymax)
    xy = elegantpair(x,y)
    
    if xy <= pairablemax(Int8)
        itype = Int8
    elseif xy <= pairablemax(Int16)
        itype = Int16
    elseif xy <= pairablemax(Int32)
        itype = Int32
    elseif xy <= pairablemax(Int64)
         itype = Int64
    elseif xy <= pairablemax(Int128)
         itype = Int128
    else
         throw(ErrorException("($xmax,$ymax) is outside of domain for paired indexing"))
    end
    return itype
end

# x, y >= 0
function elegantpair(x::T, y::T) where T<:SignedInt
    mx2 = mx = max(x,y)
    mx2 *= mx
    mx2 += x
    return mx2 + (x===mx ? y : zero(T))
end

# z >= 0
function elegantunpair(z::T) where T<:SignedInt
    isz  = isqrt(z)
    isz2 = isz*isz
    x = z - isz2
    if x < isz
        y = isz
    else
        y = x > isz ? x - isz : x
        x = isz
    end
    return x, y 
end
        
function safe_elegantpair(x::T, y::T) where T<:SignedInt
    mx = max(x,y)
    (x < 0 || y < 0 || mx > pairablemax(T)) && throw(DomainError())
    return elegantpair(x, y, mx)
end

function safe_elegantunpair(z::T) where T<:SignedInt
    z < zero(T) && throw(DomainError())
    return elegantunpair(z)
end

# x, y >= 0, mx = max(x,y)
function elegantpair(x::T, y::T, mx::T) where T<:SignedInt
    mx2 = mx
    mx2 *= mx
    mx2 += x
    return mx2 + (x===mx ? y : zero(T))
end

#=
    transform to 1-based indexing
    elegantpair(lo, hi) < elegantpair(hi, lo)
       where lo, hi > 0 and lo < hi
    assume that more often nrows > ncols
       so pair(colidx, rowidx)
=#
@inline two(::Type{T}) where T<:Integer = one(T)+one(T)

#=
pair(x::T, y::T) where T<:Signed = elegantpair(y,x) - two(T)
function pair(x::T, y::T) where T<:Signed
    mx2 = mx = max(x,y)
    mx2 *= mx
    mx2 += y
    mx2 += (y===mx ? x : zero(T))
    mx2 -= two(T)
    return mx2
end
One one machine, he version below has better consistant median time.
=#

function pair(x::T, y::T) where T<:Signed
    mx2 = mx = max(x,y)
    mx2 = mx2*mx + y
    mx2 += (y===mx ? x : zero(T))
    mx2 -= two(T)
    return mx2
end

function unpair(z::T) where T<:Signed
    y, x = elegantunpair(z + two(T))
    return x, y
end
