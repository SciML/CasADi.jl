using CasADi, Test
using PythonCall: pyconvert
include(joinpath(@__DIR__, "shared", "utils.jl"))
test_utils(SX)
test_utils(MX)
