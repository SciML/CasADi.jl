using CasADi, Test
using PythonCall: pyconvert
import LinearAlgebra: Symmetric
include(joinpath(@__DIR__, "shared", "generic.jl"))
test_generic(SX)
test_generic(MX)
