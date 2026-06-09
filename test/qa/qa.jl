using CasADi, Aqua, JET, Test

@testset "Aqua" begin
    Aqua.test_all(CasADi)
end

@testset "JET" begin
    JET.test_package(CasADi; target_defined_modules = true)
end
