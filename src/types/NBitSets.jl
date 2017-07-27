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

function Base.getindex(bitset::NBitSet{N}, index::I) where I where N
    0 < index <= N || throw(ErrorException("index $(index) is outside of the defined domain (1:$(N))")) 
    offset, bitidx = fldmod(index%Int16, 16%Int16)
    return One16 === bitset.value[offset+One16] & (One16 << (bitidx - One16))
end

function Base.setindex!(bitset::NBitSet{N}, value::Bool, index::I) where I where N
    0 < index <= N || throw(ErrorException("index $(index) is outside of the defined domain (1:$(N))")) 
    offset, bitidx = fldmod(index%Int16, 16%Int16)
    if value
        bitset.value[offset+One16] = bitset.value[offset+One16] | (One16 << (bitidx - One16))
    end
    return bitset
end

# module internal shortcut
function setindex!(bitset::NBitSet{N}, index::I) where I where N
    0 < index <= N || throw(ErrorException("index $(index) is outside of the defined domain (1:$(N))")) 
    offset, bitidx = fldmod(index%Int16, 16%Int16)
    bitset.value[offset+One16] = bitset.value[offset+One16] | (One16 << (bitidx - One16))
    return bitset
end


