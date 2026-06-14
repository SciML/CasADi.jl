using CasADi, Test
include(joinpath(@__DIR__, "shared", "numbers.jl"))
test_numbers(SX)
test_numbers(MX)
