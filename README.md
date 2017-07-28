# CardinalDicts.jl
## Fast fixed-size dictionary for keys that are or that map to sequential indicies. 

#### Copyright &copy;2017 by Jeffrey Sarnoff.  This material is made available under the MIT License.
----------------------------------------------------------------


### Purpose
This package provides the user with dictionaries where the keys are indicies 1:n, and the values are of any predetermined type.  While the total number of entries is set at construction, it is not necessary to give all keys associated values.  Values may be entered (or altered) at any time.  The data structure offers fast setting of and access to values via their indicies.  For values that are of an immutable type, the retreival time is very fast.

### Design
Each CardinalDict pairs a [multi]word indexed bitset that encodes the presence or absence of a value given an index (key) with preallocated, contiguous memory for holding values directly (if of an immutable type) or references to values of some shared type.  Values are retrieved if and only if they have been established.  Values are resettable with values of the same type.

### Exports
Your favorite Dict functions should work.  If there is something you need which is missing, please note that as an issue.

## Use

### lookup oft-used naturally sequenced values
```julia
julia> using CardinalDict

# create an CardinalDict with indices 1:20 that holds Int64 values
# populate it
# use it
# unset an index
# check it
# change an indexed value

julia> FactorialDict = CardinalDict{Int64}(20);

julia> for i in 1:20
           setindex!(FactorialDict, factorial(i), i)
        end;
        
julia> haskey(FactorialDict, 17)
true
julia> FactorialDict[17]
355_687_428_096_000

julia> clearindex!(FactorialDict, 17)
julia> haskey(FactorialDict, 17)
false
julia> get(FactorialDict, 17, 0)
0

julia> FactorialDict[2]
2
julia> FactorialDict[2] = 1234
julia> FactorialDict[2]
1234
```
### dynamic valuation
