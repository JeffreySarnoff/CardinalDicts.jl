#=>
     Julia can be yet more snappy when register-focused use
        (bitshifts, offsets) keeps counts in Int32 registers.
     Advantages are entirely system dependant, often found.
     The functions in this file allow us to choose the Signed
        type used for indexing most parsimoneously -- and here
        we use the smallest system integer type that suffices.
<=#

bitsof(::Type{T}) where T = sizeof(T) << 3

const TYPES_FOR_INDEXING = [ Int8, Int16, Int32, Int64, Int128 ];

function type_for_indexing(posint::T) where T<:Signed
    posint <= 0 && throw(ErrorException("posint ($(posint)) must be > 0"))

    bits_required = bitsof(T) - leading_zeros(posint)
    type_index = nextpow2(bits_required + 1) >>> 2
    type_index = trailing_zeros(type_index)
    type_index = max(1, min(5, type_index))

    return TYPES_FOR_INDEXING[ type_index ]
end
