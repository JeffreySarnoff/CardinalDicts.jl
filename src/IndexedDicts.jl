module IndexedDicts

export IndexedDict

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
function signedtype_required(posint::T) where T<:Integer
   type_index = nextpow2(bits_required(posint) + one(T)) >>> 3%T
   return TypeForIndexing[ min(9%T, type_index) ]
end
  
include("types/IndexedDict.jl")
include("dict/workalike.jl")

end # module
