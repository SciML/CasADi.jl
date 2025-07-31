using Test, CasADi
import LinearAlgebra: cross, ×, Symmetric
import Suppressor: @capture_out
using PythonCall

include("constructors.jl")
include("generic.jl")
include("importexport.jl")
include("mathfuns.jl")
include("mathops.jl")
include("numbers.jl")
include("types.jl")
include("utils.jl")

for i in [SX, MX]
    test_constructors(i)
    test_generic(i)
    test_importexport(i)
    test_mathfuns(i)
    test_mathops(i)
    test_numbers(i)
    test_types(i)
    test_utils(i)
end

## Test examples
@testset "Test first example                                " begin
    x = SX("x")
    y = SX("y")
    α = 1
    b = 100
    f = (α - x)^2 + b * (y - x^2)^2

    nlp = Dict("x" => vcat([x; y]), "f" => f)
    S = nlpsol(
        "S",
        "ipopt",
        nlp,
        Dict("ipopt" => Dict(["print_level" => 0]), "verbose" => false)
    )

    sol = solve(S, x0 = [0, 0])
    @test sol["x"] ≈ [0.9999999999999899, 0.9999999999999792]
end

@testset "Test second example                               " begin
    opti = Opti()

    x = variable!(opti)
    y = variable!(opti)

    minimize!(opti, (y - x^2)^2)
    subject_to!(opti, x^2 + y^2 == 1)
    subject_to!(opti, x + y >= 1)

    solver!(opti, "ipopt", Dict("verbose" => false), Dict("print_level" => 0))
    sol = solve!(opti)

    @test value(sol, x) ≈ 0.7861513776531158
    @test value(sol, y) ≈ 0.6180339888825889
end
