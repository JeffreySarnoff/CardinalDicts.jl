module NBitSets

export NBitSet,
       unsafe_getidx, unsafe_setidx!

@inline bitsof(::Type{T}) where T<:Integer = sizeof(T)<<3

struct NBitSet{T}
    value::Vector{T}
    nbits::T

    function NBitSet(nbits::I) where I<:Integer
        nbits > typemax(I)>>2 && throw(ErrorException("An NBitSet{$(I)} is limited to $(typemax(I)>>2) bits."))
        noftype = cld(nbits, bitsof(I)%I)
        zeroed  = zeros(I, noftype)
        return new{I}(zeroed, noftype)
    end
end

Base.length(bitset::NBitSet{N}) where N = bitset.nbits

@inline function bitdex(index::I) where I<:Integer
    offset, index = fldmod(index, bitsof(I)%I)
    # offset = offset + one(I)
    return offset, index
end
#@inline bitdex(index::I)::I where I<:Integer = fldmod(index, sizeof(I)%I)

@inline setbit(bits::I, index::I) where I<:Integer =  (bits | (one(I) << (index-one(I))))::I
@inline getbit(bits::I, index::I) where I<:Integer = ((bits | (one(I) << (index-one(I)))) !== zero(i))::Bool


#@inline setbit(bits::I, index::I)::I where I<:Integer = bits | (one(I) << (index-one(I)))
#@inline getbit(bits::I, index::I)::I = (bits & (One16 << (index-One16))) !== zero(Int16)

function Base.getindex(bitset::NBitSet{N}, index::I) where I where N
    0 < index <= length(bitset) || throw(ErrorException("index $(index) is outside of the defined domain (1:$(N))")) 
    offset, bitidx = bitdex(index)
    return one(I) === getbit(bitset.value[offset+one(I)], bitidx)
 end

function Base.setindex!(bitset::NBitSet{N}, value::Bool, index::I) where I where N
    0 < index <= N || throw(ErrorException("index $(index) is outside of the defined domain (1:$(N))")) 
    offset, bitidx = bitdex(index)
    if value
        offset_plus1 = offset+one(I)
        bitset.value[offset_plus1] = setbit(bitset.value[offset_plus1], bitidx)
    end
    return bitset
end

# module internal shortcuts

function unsafe_getidx(bitset::NBitSet{N}, index::I) where I where N
    offset, bitidx = bitdex(index)
    return one(I) === getbit(bitset.value[offset+one(I)], bitidx)
 end

function unsafe_setidx!(bitset::NBitSet{N}, index::I) where I where N
    offset, bitidx = bitdex(index)
    offset_plus1 = offset+one(I)
    bitset.value[offset_plus1] = setbit(bitset.value[offset_plus1], bitidx)
    return bitset
end

end # module

