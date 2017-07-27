struct NBitSet{N}
    value::Vector{Int16}
    
    function NBitSet(elements::E) where E<:Integer
        nInt16s = cld(elements, 16)
        zeroed  = zeros(Int16, nInt16s)
        return new{elements}(zeroed)
    end
end

Base.length(bitset::NBitSet{N}) where N = N
Base.typemax(bitset::NBitSet{N}) where N = fldmod(N, 16)

function Base.getindex(bitset::NBitSet{N}, index::I) where I where N
    0 < index <= N || throw(ErrorException("index $(index) is outside of the defined domain (1:$(N))")) 
    offset, bitidx = fldmod(index%Int16, 16%Int16)
    return one(Int16) === (bitset.value[offset+1] >> (15%Int16 - bitidx%Int16)) & one(Int16)
end

function Base.setindex!(bitset::NBitSet{N}, value::Bool, index::I) where I where N
    0 < index <= N || throw(ErrorException("index $(index) is outside of the defined domain (1:$(N))")) 
    offset, bitidx = fldmod(index%Int16, 16%Int16)
    if value
        bitset.value[offset+1] = bitset.value[offset+1] | (one(Int16) << bitidx)
    end
    return bitset
end
