#=>
     Julia can be yet more snappy when register-focused use
        (bitshifts, offsets) keeps counts in Int32 registers.
     Advantages are entirely system dependant, often found.

     The functions in this file allow us to choose the Signed
        type used for indexing most parsimoneously -- and here
        we use the smallest system integer type that suffices.
<=#

const SUN =
  Union{  Int128,  Int64,  Int32,  Int16,  Int8,
         UInt128, UInt64, UInt32, UInt16, UInt8  }

bitsof(::Type{Int8})    = Int8(8)
bitsof(::Type{Int16})   = Int16(16)
bitsof(::Type{Int16})   = Int16(16)
bitsof(::Type{Int32})   = Int32(32)
bitsof(::Type{Int64})   = Int64(64)
bitsof(::Type{Int128})  = Int128(128)

bitsof(::Type{UInt8})   = Int8(8)
bitsof(::Type{UInt16})  = Int16(16)
bitsof(::Type{UInt32})  = Int32(32)
bitsof(::Type{UInt64})  = Int64(64)
bitsof(::Type{Int128})  = Int128(128)

bitsof(::Type{Float16}) = Int16(16)
bitsof(::Type{Float32}) = Int32(32)
bitsof(::Type{Float64}) = Int64(64)


const TYPES_FOR_INDEXING = [ Int8, Int16, Int32, Int64, Int128 ];

function type_for_indexing(posint::T) where T<:SUN
    posint < 0 && throw(ErrorException("posint ($(posint)) must be => 0"))
    posint = max(127%T, posint)

    type_index = nextpow2(bits_required(posint) + 1) >>> 2
    type_index = trailing_zeros(type_index)
    type_index = max(1, min(5, type_index))

    return TYPES_FOR_INDEXING[ type_index ]
end

function bits_required(posint::T)::T where T<:Integer
    posint > 0 || throw(ErrorException("posint ($(posint)) must be > 0"))
    return bitsof(T) - leading_zeros(posint)%T
end
