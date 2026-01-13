function test_mathops(::Type{T}) where {T <: CasadiSymbolicObject}
    @testset "$(string("Unary operations for ", T, "                          "))" begin
        x = randn()

        @test to_julia(-T(x)) ≈ -x
    end

    @testset "$(string("Binary operations for ", T, "                         "))" begin
        x = rand()
        y = rand()

        @test to_julia(T(x) + T(y)) ≈ x + y
        @test to_julia(T(x) * T(y)) ≈ x * y
        @test to_julia(T(x) - T(y)) ≈ x - y
        @test to_julia(T(x) / T(y)) ≈ x / y
        @test to_julia(T(x)^T(y)) ≈ x^y
        @test to_julia(T(x) \ T(y)) ≈ x \ y
    end

    @testset "$(string("Comparisons for ", T, "                               "))" begin
        x = randn()
        y = x + rand()

        @test Bool(to_julia(T(y) >= T(x)))
        @test Bool(to_julia(T(y) > T(x)))
        @test Bool(to_julia(T(x) <= T(y)))
        @test Bool(to_julia(T(x) < T(y)))
        @test Bool(to_julia(T(x) == T(x)))
    end

    @testset "$(string("Cross product for ", T, "                             "))" begin
        n₁ = rand(3)
        n₂ = rand(3)
        c₁ = T(n₁)
        c₂ = T(n₂)

        n₁₂ = n₁ × n₂
        c₁₂ = c₁ × c₂
        @test to_julia(c₁₂) == n₁₂

        c₁₂ = cross(c₁, c₂)
        @test to_julia(c₁₂) == n₁₂
    end

    return @testset "Sum" begin
        a = T([1, 2, 3, 4])
        @test isequal(to_julia(sum(a)), 10)
        b = T(3, 3)
        @test isequal(to_julia(sum(b)), 0)
        @test isequal(to_julia(sum(b, dims = 1)), [0, 0, 0]')
        @test isequal(to_julia(sum(b, dims = 2)), [0, 0, 0])
    end
end
