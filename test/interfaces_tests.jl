using CasADi, LinearAlgebra, PythonCall, Test

struct GenericCasadiWrapper <: CasadiSymbolicObject
    x
end

@testset "CasadiSymbolicObject interface" begin
    x = GenericCasadiWrapper(casadi.SX(2.0))
    y = GenericCasadiWrapper(casadi.SX(3.0))
    symbolic_x = GenericCasadiWrapper(casadi.SX.sym("generic_x"))
    symbolic_y = GenericCasadiWrapper(casadi.SX.sym("generic_y"))
    matrix = GenericCasadiWrapper(casadi.SX([[1.0, 2.0], [3.0, 4.0]]))

    @test !(x isa Number)
    broadcastable_matrix = Base.Broadcast.broadcastable(matrix)
    @test broadcastable_matrix isa Ref
    @test broadcastable_matrix[] === matrix
    @test eltype(GenericCasadiWrapper) === GenericCasadiWrapper
    @test LinearAlgebra.symmetric(x) === x
    @test LinearAlgebra.symmetric_type(GenericCasadiWrapper) === GenericCasadiWrapper
    @test to_julia(x + y) == 5.0
    @test to_julia(2 - x) == 0.0
    @test to_julia(x * y) == 6.0
    @test Bool(to_julia(x < y))
    @test pyconvert(
        Bool,
        casadi.is_equal(
            substitute(symbolic_x + symbolic_y, symbolic_x, symbolic_y), symbolic_y + symbolic_y, 3
        )
    )
    @test size(matrix) == (2, 2)
    @test to_julia(matrix) == [1.0 2.0; 3.0 4.0]
    @test to_julia(matrix[2, 1]) == 3.0
    @test to_julia(sum(matrix)) == 10.0
    @test setindex!(matrix, x, 1, 1) === matrix
    @test to_julia(matrix[1, 1]) == 2.0
end
