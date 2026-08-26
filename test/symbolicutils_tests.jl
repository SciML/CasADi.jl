using CasADi, SymbolicUtils, Test

@testset "SymbolicUtils array construction" begin
    for T in (SX, MX)
        x = T("x")
        inferred = SymbolicUtils.Code.create_array(
            T, nothing, Val(1), Val((2,)), x, x^2
        )
        typed = SymbolicUtils.Code.create_array(
            T, T, Val(1), Val((2,)), x, x^2
        )

        @test inferred isa T
        @test size(inferred) == (2, 1)
        @test typed isa T
        @test size(typed) == (2, 1)
    end
end
