using CasADi, Test
include(joinpath(@__DIR__, "shared", "mathfuns.jl"))
test_mathfuns(SX)
test_mathfuns(MX)
