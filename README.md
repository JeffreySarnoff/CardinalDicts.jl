# CardinalDicts.jl
## Fast fixed-size dictionary for keys that are or that map to sequential indicies. 

#### Copyright &copy;2017 by Jeffrey Sarnoff.  This material is made available under the MIT License.
----------------------------------------------------------------


### Purpose
This package provides the user with dictionaries where the keys are indicies 1:n, and the values are of any predetermined type.  While the total number of entries is set at construction, it is not necessary to give all keys associated values.  Values may be entered (or altered) at any time.  The data structure offers fast setting of and access to values via their indicies.  For values that are of an immutable type, the retrieval time is very fast.

### Overview
This small package that couples a BitVector with a preallocated Vector{T} for some T to allow faster get/set for sequentially available information (or naturally 1:n keyed values), where any values may change or may be/become unavailable.  The semantics for inaccessible [absent] values is up to you.  The little benchmarking I have done is encouraging.

### Design
Each CardinalDict pairs a [multi]word indexed bitset that encodes the presence or absence of a value given an index (key) with preallocated, contiguous memory for holding values directly (if of an immutable type) or references to values of some shared type.  Values are retrieved if and only if they have been established.  Values are resettable with values of the same type.

### Offers
#### exports
CardinalDict, keymax(dict::CardinalDict), clearindex!(dict:CardinalDict, key::Integer), isfull(dict:CardinalDict)
   - clearindex! is like delete! if delete! returned nothing   
   - isfull is the dual of isempty   
   - keymax yeilds the largest admissible key for a given CardinalDict (this value is established at construction)
#### provides
==, !=, length, isempty, endof, eltype, keys, values, getindex, setindex!, delete!, empty!,    
get(dict::CardinalDict{K,V}, key::K, default::V), get!(dict::CardinalDict{K,V}, key::K, default::V),    
start, next, done, in (and ∈, ∋, ∉, ∌), string, show    

Your favorite Dict functions should work.  If there is something you need which is missing, please note that as an issue.    

## Use

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
