using CasADi, Test

@testset "Precompile workload API" begin
    x = SX("x")
    expression = x^2 + 2x + 1
    @test to_julia(substitute(expression, x, 1)) == 4.0
    @test to_julia(DM([1.0, 2.0])) == [1.0, 2.0]

    opti = Opti()
    z = variable!(opti)
    subject_to!(opti, z >= 0)
    minimize!(opti, z^2)
    @test return_status(opti) isa String
end
