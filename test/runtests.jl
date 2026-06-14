using SafeTestsets, Test

# Keep `using CasADi` in Main: the per-type test functions build CasADi
# references and testset titles via `string(T)` (e.g. `Meta.parse(string("casadi.", T))`),
# and `show`/`string` qualifies a type by its visibility in `Base.active_module()` (Main).
# Without the bare names here, `string(SX)` becomes "CasADi.SX" and breaks that logic.
using CasADi

# Each independent test unit runs in its own module via `@safetestset`
# (matching the canonical SciML structure). The per-type test functions
# live in the included files; each `@safetestset` body `using`s what that
# file needs, includes it, then calls the function for one symbolic type.

@safetestset "Constructors SX" begin
    using CasADi, Test
    using PythonCall: pyconvert, Py
    include("constructors.jl")
    test_constructors(SX)
end

@safetestset "Generic SX" begin
    using CasADi, Test
    using PythonCall: pyconvert
    import LinearAlgebra: Symmetric
    include("generic.jl")
    test_generic(SX)
end

@safetestset "Import/export SX" begin
    using CasADi, Test
    include("importexport.jl")
    test_importexport(SX)
end

@safetestset "Math functions SX" begin
    using CasADi, Test
    include("mathfuns.jl")
    test_mathfuns(SX)
end

@safetestset "Math operations SX" begin
    using CasADi, Test
    import LinearAlgebra: cross, ×
    include("mathops.jl")
    test_mathops(SX)
end

@safetestset "Numbers SX" begin
    using CasADi, Test
    include("numbers.jl")
    test_numbers(SX)
end

@safetestset "Types SX" begin
    using CasADi, Test
    import Suppressor: @capture_out
    include("types.jl")
    test_types(SX)
end

@safetestset "Utils SX" begin
    using CasADi, Test
    using PythonCall: pyconvert
    include("utils.jl")
    test_utils(SX)
end

@safetestset "Constructors MX" begin
    using CasADi, Test
    using PythonCall: pyconvert, Py
    include("constructors.jl")
    test_constructors(MX)
end

@safetestset "Generic MX" begin
    using CasADi, Test
    using PythonCall: pyconvert
    import LinearAlgebra: Symmetric
    include("generic.jl")
    test_generic(MX)
end

@safetestset "Import/export MX" begin
    using CasADi, Test
    include("importexport.jl")
    test_importexport(MX)
end

@safetestset "Math functions MX" begin
    using CasADi, Test
    include("mathfuns.jl")
    test_mathfuns(MX)
end

@safetestset "Math operations MX" begin
    using CasADi, Test
    import LinearAlgebra: cross, ×
    include("mathops.jl")
    test_mathops(MX)
end

@safetestset "Numbers MX" begin
    using CasADi, Test
    include("numbers.jl")
    test_numbers(MX)
end

@safetestset "Types MX" begin
    using CasADi, Test
    import Suppressor: @capture_out
    include("types.jl")
    test_types(MX)
end

@safetestset "Utils MX" begin
    using CasADi, Test
    using PythonCall: pyconvert
    include("utils.jl")
    test_utils(MX)
end

## Test examples
@safetestset "Test first example                                " begin
    using CasADi, Test

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

@safetestset "Test second example                               " begin
    using CasADi, Test

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
