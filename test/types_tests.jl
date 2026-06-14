using CasADi, Test
import Suppressor: @capture_out
include(joinpath(@__DIR__, "shared", "types.jl"))
test_types(SX)
test_types(MX)
