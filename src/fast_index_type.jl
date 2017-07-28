
#=
    Julia is a bit even more snappy when indicies, bitshifts and other register-centric ops
        are performed with Int16 or Int32 values.  Int64 values are very fast, too.
     The functions I use to optimize the type of the indexing value are needed
        when they are being leaned upon to provide time-minimized access.
=#

bitsof(::Type{T}) where T = sizeof(T) * 8
@inline function bitsof(::Type{T})::T where T<:Integer
    return sizeof(T)%T << (one(T)+one(T)+one(T))
end
 
function bits_required(posint::T)::T where T<:Integer
    posint > 0 || throw(ErrorException("posint ($(posint)) must be > 0"))
    bitsize = bitsof(T)
    return bitsize - leading_zeros(posint)%T
end

const TypeForIndexing = [Int8, Int16, Int32, Int32, Int64, Int64, Int64, Int64, Int128 ]

function type_for_indexing(posint::T) where T<:Integer
   type_index = nextpow2(bits_required(posint) + one(T)) >>> 3%T
   return TypeForIndexing[ min(9%T, type_index) ]
end
