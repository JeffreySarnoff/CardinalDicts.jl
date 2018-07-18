# CardinalDicts.jl
### Fast fixed-size dicts wth eraseable entries (values) for keys that are or map to sequential indicies.

----

#### Copyright ©&thinsp;2018 by Jeffrey Sarnoff. &nbsp;&nbsp; This work is made available under The MIT License.
--------


### Purpose
- This package provides the user with dictionaries where the keys are indicies 1:n, and the values are of a given type.    
- While the total number of entries is set at construction, it is not necessary to give all keys associated values.
- Values may be entered, altered or cleared at any time using their indices.
- Clearing a value may be interpreted as setting it to unavailable, unknown, or unused.
- For immutably typed values, set/get/reset/clear times are very fast.

### Overview
This small package that couples a BitVector with a preallocated Vector{T} for some T to allow faster get/set for sequentially available information (or naturally 1:n keyed values), where any values may change or may be/become unavailable.  The semantics for inaccessible [absent] values is up to you.  The little benchmarking I have done is encouraging.

### Design
#### CardinalDict
Each CardinalDict pairs a [multi]word indexed bitset that encodes the presence or absence of a value given an index (key) with preallocated, contiguous memory for holding values directly (if of an immutable type) or references to values of some shared type.  Values are retrieved if and only if they have been established.  Values are resettable with values of the same type.
#### CardinalPairDict
Each CardinalPairDict pairs a [multi]word indexed bitset that encodes the presence or absence of a value
given an indexing pair (xkey, ykey_key)  ith preallocated, contiguous memory for holding values
directly (if of an immutable type) or references to values of some shared type.
Values are retrieved if and only if they have been established.  Values are resettable with values of the same type.

When using large CardinalPairDicts where the maximum index in one dimension is considerably larger than the maximum index in the se other dimension, it is more memory conservative and more performant in use to construct the ComardinalPairDict with the larger of the two indicies [(x, y), (row, col)] given first:
```julia
smaller_max_index, larger_max_index = minmax(one_max_index, the_other_max_index)
value_type = String
prefer_this_pairdict = CardinalPairDict{value_type}(larger_max_index, smaller_max_index)
```
Organizing it the other way, with the smaller maximum index given first, entails `~(larger_max - smaller_max)` additional storage cells and distributes "adjacent" pairs less densly.  It is worthwhile tbenchmarking both organizations if the difference is large.

### Offers
#### exports
CardinalDict, keymax(dict::CardinalDict), clearindex!(dict:CardinalDict, key::Integer), isfull(dict:CardinalDict)
   - clearindex! is like delete! if delete! returned nothing   
   - isfull is the dual of isempty   
   - keymax yields the largest admissible key for a given CardinalDict (established at construction)
   - keysmax yields the largest admissible key pair for a given CardinalPairDict (established at construction)
#### provides
==, !=, length, isempty, endof, eltype, keys, values, getindex, setindex!, delete!, empty!,    
get(dict::CardinalDict{K,V}, key::K, default::V), get!(dict::CardinalDict{K,V}, key::K, default::V),    
start, next, done, in (and ∈, ∋, ∉, ∌), string, show    

Your favorite Dict functions should work.  If there is something you need which is missing, please note that as an issue.    

## Use CardinalDicts

### lookup oft-used naturally sequenced values
```julia

#=
  create an CardinalDict with indices 1:20 that holds Int64 values
  check length
  confirm keymax
  populate it
  use it
  unset an index
  check it
  reassign an indexable value
=#

using CardinalDicts

factorials = CardinalDict{Int64}(20);

length(factorials) == 0
keymax(factorials) == 20

for i in 1:20
    setindex!(factorials, factorial(i), i)
end

length(factorials) == 20
keymax(factorials) == 20
haskey(factorials, 17) == true
factorials[17] == factorial(17)
```
### construct from a vector or the stringized form
```julia

using CardinalDicts

vec = [1.0, 3.0, 2.0]
dict = CardinalDict(vec)
dict[2] == 3.0
keymax(dict) == 3
isfull(dict) == true

dict2 = eval(parse(string(dict)))
dict == dict2
```

### exercise api
```julia

using CardinalDicts

tenfold = CardinalDict{String}(40);
length(tenfold) == 0
endof(tenfold) == 0
keymax(tenfold) == 40
keys(tenfold) == []
values(tenfold) == []

tenfold[20] = "200";
tenfold[25] = "250";
tenfold[26] = "260";

length(tenfold) == 3
endof(tenfold) == 26
keymax(tenfold) == 40

keys(tenfold) == Int8[20, 25, 26]
values(tenfold) == String["200", "250", "260"]
eltype(tenfold) == Pair{Int8, String}

clearindex!(tenfold, 20)
haskey(tenfold, 20) == false
get(tenfold, 20, "0") == "0"

tenfold[20] = "200"
haskey(tenfold, 20) == true
get(tenfold, 20, "0") == "200"

tenfold == eval(parse(string(tenfold)))
```


## Use CardinalPairDicts

### lookup oft-used naturally pair-indexed values
```julia

#=
  define type Stringy that holds a string
  create a CardinalPairDict
      with paired indices (1:5, 1:4) that holds Stringy values
=#

using CardinalDicts

mutable struct Stringy
    value::String
end
value(x::Stringy) = x.value
value(x::Stringy, s::String) = begin x.value = s end
Base.:(==)(x::Stringy, y::Stringy) = value(x) == value(y)

nrows = 5; ncols = 4; n = ncols*nrows
ints = collect(1:n)
matrix_of_ints = reshape(ints, nrows, ncols)
matrix_of_strs = string.(matrix_of_ints)

pairdict = CardinalPairDict{Stringy}(size(matrix_of_strs)...);

length(pairdict) == 0
isempty(pairdict) == true
isfull(pairdict)  == false

haskey(pairdict, 3, 2) == false
get(pairdict, 3, 2, Stringy("0")) == Stringy("0")
```
### construct from a matrix
```julia
mutable struct Stringy
    value::String
end

frommat = CardinalPairDict(Stringy.(matrix_of_strs))
keys(frommat) == keys(pairdict)
values(frommat) == values(pairdict)
```
### exercise api
```julia
using CardinalDicts

mutable struct Stringy
    value::String
end

value(x::Stringy) = x.value
function value(x::Stringy, s::String)
    x.value = s
    return x
end
Base.:(==)(x::Stringy, y::Stringy) = value(x) == value(y)

nrows = 5; ncols = 4; n = ncols*nrows
ints = collect(1:n)
matrix_of_ints = reshape(ints, nrows, ncols)
matrix_of_strs = string.(matrix_of_ints)

pairdict = CardinalPairDict{Stringy}(size(matrix_of_strs)...);

for r in 1:nrows
    for c in 1:ncols
        stringy = Stringy(getindex(matrix_of_strs, r, c))
        setindex!(pairdict, stringy, r, c)
    end
end

length(pairdict) == n
isempty(pairdict) == false
isfull(pairdict)  == true

haskey(pairdict, 3, 2) == true
value(getindex(pairdict, 3, 2)) == matrix_of_strs[3,2]
```
