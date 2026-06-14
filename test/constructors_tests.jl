# Keep `using CasADi` so the per-type test functions resolve bare type names
# (`string(SX)` must be "SX", not "CasADi.SX") via `Base.active_module()`.
using CasADi, Test
using PythonCall: pyconvert, Py
include(joinpath(@__DIR__, "shared", "constructors.jl"))
test_constructors(SX)
test_constructors(MX)
