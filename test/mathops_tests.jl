using CasADi, Test
import LinearAlgebra: cross, ×
include(joinpath(@__DIR__, "shared", "mathops.jl"))
test_mathops(SX)
test_mathops(MX)
