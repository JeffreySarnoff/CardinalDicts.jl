module NBitSets

export NBitSet,
       unsafe_getidx, unsafe_setidx!

struct NBitSet{N}
    value::Vector{Int16}
    
    function NBitSet(elements::E) where E<:Integer
        nInt16s = cld(elements, 16)
        zeroed  = zeros(Int16, nInt16s)
        return new{elements}(zeroed)
    end
end

Base.length(bitset::NBitSet{N}) where N = N%Int16

const One16 = one(Int16)

@inline bitdex(index::Int16)::Int16 = fldmod(index, 16%Int16)
@inline setbit(bits::Int16, index::Int16)::Int16 = bits | (One16 << (index-One16))
@inline getbit(bits::Int16, index::Int16)::Int16 = (bits & (One16 << (index-One16))) !== zero(Int16)

function Base.getindex(bitset::NBitSet{N}, index::I) where I where N
    0 < index <= N || throw(ErrorException("index $(index) is outside of the defined domain (1:$(N))")) 
    offset, bitidx = bitdex(index%Int16)
    return One16 === getbit(bitset.value[offset+One16], bitidx)
 end

function Base.setindex!(bitset::NBitSet{N}, value::Bool, index::I) where I where N
    0 < index <= N || throw(ErrorException("index $(index) is outside of the defined domain (1:$(N))")) 
    offset, bitidx = bitdex(index%Int16)
    if value
        bitset.value[offset+One16] = setbit(bitset.value[offset+One16], bitidx)
    end
    return bitset
end

# module internal shortcuts

function unsafe_getidx(bitset::NBitSet{N}, index::I) where I where N
    offset, bitidx = bitdex(index%Int16)
    return One16 === getbit(bitset.value[offset+One16], bitidx)
 end

function unsafe_setidx!(bitset::NBitSet{N}, index::I) where I where N
    offset, bitidx = bitdex(index%Int16)
    bitset.value[offset+One16] = setbit(bitset.value[offset+One16], bitidx)
    return bitset
end

end # module

