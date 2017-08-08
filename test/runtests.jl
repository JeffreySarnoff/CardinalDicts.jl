using CardinalDicts
using Base.Test

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

factorials = CardinalDict{Int64}(20);

@test length(factorials) == 0
@test keymax(factorials) == 20

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

Factorials[17] = factorial(17)
@test factorials[17] == factorial(17)

vec = [1.0, 3.0, 2.0]
fromvec = CardinalDict(vec)
@test fromvec[2] == 3.0
@test keymax(fromvec) == 3
@test isfull(fromvec) == true

# Container, Associative interface

tenfold = CardinalDict{Int32}(40)
@test length(tenfold) == 0
@test endof(tenfold) == 0
@test keymax(tenfold) == 40
@test keys(tenfold) == []
@test values(tenfold) == []
tenfold[20] = 200%Int32
tenfold[25] = 250%Int32
tenfold[26] = 260%Int32
@test length(tenfold) == 3
@test endof(tenfold) == 26
@test keymax(tenfold) == 40
@test keys(tenfold) == Int8[20, 25, 26]
@test values(tenfold) == Int32[200, 250, 260]
@test eltype(tenfold) == Pair{Int16, Int32}
