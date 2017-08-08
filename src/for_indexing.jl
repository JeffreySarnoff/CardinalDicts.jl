
#=
    Julia is a bit even more snappy when indicies, bitshifts and other register-centric ops
        are performed with Int16 or Int32 values.  Int64 values are very fast, too.
     The functions I use to optimize the type of the indexing value are needed
        when they are being leaned upon to provide time-minimized access.
=#

@inline bitsof(::Type{T}) where T = sizeof(T) * 8
bitsof(x::T) where T = bitsof(T)

function bits_required(posint::T)::T where T<:Integer
    posint > 0 || throw(ErrorException("posint ($(posint)) must be > 0"))
    return bitsof(T) - leading_zeros(posint)%T
end

const TYPES_FOR_INDEXING = [ Int8, Int16, Int32, Int64, Int128 ]

function type_for_indexing(posint::T) where T<:Union{Int8, Int16, Int32, Int64, Int128}
    posint < 0 && throw(ErrorException("posint ($(posint)) must be => 0"))
    posint = max(127%T, posint)
    type_index = nextpow2(bits_required(posint) + 1) >>> 2
    type_index = trailing_zeros(type_index)
    type_index = max(1, min(5, type_index))
    return TYPES_FOR_INDEXING[ type_index ]
end
    
