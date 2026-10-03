using CasADi, Test

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

@testset "Typed nested nlpsol options (issue #45)           " begin
    x = SX("x")
    problem = Dict("x" => x, "f" => (x - 1)^2)
    options = Dict{String, Dict{String, Int}}("ipopt" => Dict("print_level" => 0))
    options_before = deepcopy(options)
    solver = nlpsol("solver", "ipopt", problem, options)
    @test solver isa CasADi.CasadiFunction
    @test options == options_before
    @test options == Dict("ipopt" => Dict("print_level" => 0))
    @test options["ipopt"] isa Dict{String, Int}
    sol = solve(solver; x0 = [0.0])
    @test sol["x"] ≈ 1.0
end

@testset "Typed nested qpsol options (issue #45)            " begin
    x = SX("x")
    qp = Dict("x" => x, "f" => (x - 1)^2)
    options = Dict{String, Dict{String, Bool}}("osqp" => Dict("verbose" => false))
    options_before = deepcopy(options)
    solver = qpsol("q", "osqp", qp, options)
    @test solver isa CasADi.CasadiFunction
    @test options == options_before
    @test options == Dict("osqp" => Dict("verbose" => false))
    @test options["osqp"] isa Dict{String, Bool}
    sol = solve(solver; x0 = [0.0])
    @test sol["x"] ≈ 1.0 atol = 1.0e-5
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

@testset "Typed flat and nested solver! options             " begin
    # (a) Flat typed s_opts for ipopt: end-to-end solve; caller dicts unchanged.
    opti = Opti()
    x = variable!(opti)
    minimize!(opti, (x - 1)^2)
    plugin_options = Dict{String, Bool}("print_time" => false)
    solver_options = Dict{String, Int}("print_level" => 0)
    plugin_before = deepcopy(plugin_options)
    solver_before = deepcopy(solver_options)
    solver!(opti, "ipopt", plugin_options, solver_options)
    @test plugin_options == plugin_before
    @test solver_options == solver_before
    sol = solve!(opti)
    @test value(sol, x) ≈ 1.0

    # (b) Typed nested qpsol_options in p_opts for sqpmethod: end-to-end solve.
    opti2 = Opti()
    y = variable!(opti2)
    minimize!(opti2, (y - 1)^2)
    plugin_options2 = Dict{String, Any}(
        "qpsol" => "qrqp",
        "qpsol_options" => Dict{String, Bool}("print_iter" => false),
    )
    solver_options2 = Dict{String, Bool}()
    plugin_before2 = deepcopy(plugin_options2)
    solver_before2 = deepcopy(solver_options2)
    solver!(opti2, "sqpmethod", plugin_options2, solver_options2)
    @test plugin_options2 == plugin_before2
    @test solver_options2 == solver_before2
    @test plugin_options2["qpsol_options"] isa Dict{String, Bool}
    sol2 = solve!(opti2)
    @test value(sol2, y) ≈ 1.0
end
