using CardinalDicts
using Base.Test
import CardinalDictionaries: pair, unpair

#=
  create a CardinalDict 
      with indices 1:20 that holds Int64 values
  check length
  confirm keymax
  populate it
  use it
  unset an index
  check it
  reassign an indexable value
=#

factorials = CardinalDict{Int64}(20);

@test length(factorials) == 0
@test keymax(factorials) == 20
@test isempty(factorials) == true

for i in 1:20
    setindex!(factorials, factorial(i), i)
end

@test length(factorials) == 20
@test keymax(factorials) == 20

@test haskey(factorials, 17) == true
@test factorials[17] == factorial(17)

delete!(factorials, 17)
@test haskey(factorials, 17) == false
@test get(factorials, 17, 0) == 0

factorials[17] = factorial(17)
@test factorials[17] == factorial(17)

vec = [1.0, 3.0, 2.0]
fromvec = CardinalDict(vec)
@test fromvec[2] == 3.0
@test keymax(fromvec) == 3
@test isfull(fromvec) == true

# Container, Associative interface

tenfold = CardinalDict{String}(40)
@test length(tenfold) == 0
@test endof(tenfold) == 0
@test keymax(tenfold) == 40
@test keys(tenfold) == []
@test values(tenfold) == []

tenfold[20] = "200"
tenfold[25] = "250"
tenfold[26] = "260"

@test length(tenfold) == 3
@test endof(tenfold) == 26
@test keymax(tenfold) == 40
@test keys(tenfold) == Int8[20, 25, 26]
@test values(tenfold) == String["200", "250", "260"]
@test eltype(tenfold) == Pair{Int8, String}

delete!(tenfold, 20)
@test haskey(tenfold, 20) == false
@test get(tenfold, 20, "0") == "0"

tenfold[20] = "200"
@test haskey(tenfold, 20) == true
@test get(tenfold, 20, "0") == "200"

# etc
#=
tenfold2 = eval(parse(string(tenfold)))
@test tenfold == tenfold2
=#


#=
  define type Stringy that holds a string
  create a CardinalPairDict
      with paired indices (1:5, 1:4) that holds Stringy values
  check length
  confirm keymax
  populate it
  use it
  unset an index
  check it
  reassign an indexable value
=#

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

@test length(pairdict) == 0
@test keymax(pairdict) == pair(nrows, ncols)
@test isempty(pairdict) == true
@test isfull(pairdict)  == false

for r in 1:nrows
    for c in 1:ncols
        stringy = Stringy(getindex(matrix_of_strs, r, c))
        setindex!(pairdict, stringy, r, c)
    end
end

@test length(pairdict) == n
@test keymax(pairdict) == pair(nrows, ncols)
@test isempty(pairdict) == false
@test isfull(pairdict)  == false

@test haskey(pairdict, 3, 2) == true
@test value(getindex(pairdict, 3, 2)) == matrix_of_strs[3,2]

frommat = CardinalPairDict(Stringy.(matrix_of_strs))
@test keys(frommat) == keys(pairdict)
@test values(frommat) == values(pairdict)

delete!(pairdict, 3, 2)
@test haskey(pairdict, 3, 2) == false
@test get(pairdict, 3, 2, Stringy("0")) == Stringy("0")
