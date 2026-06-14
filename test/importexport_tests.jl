using CasADi, Test
include(joinpath(@__DIR__, "shared", "importexport.jl"))
test_importexport(SX)
test_importexport(MX)
