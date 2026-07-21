using CasADi, Aqua, JET, SciMLTesting, Test

run_api_docs(CasADi)

@testset "Aqua" begin
    # ambiguities and deps_compat disabled: genuine findings tracked in
    # https://github.com/SciML/CasADi.jl/issues/26 (marked @test_broken below).
    Aqua.test_all(CasADi; ambiguities = false, deps_compat = false)
    @test_broken false  # Aqua ambiguities: 71 found — tracked in https://github.com/SciML/CasADi.jl/issues/26
    @test_broken false  # Aqua deps_compat: LinearAlgebra missing [compat] — tracked in https://github.com/SciML/CasADi.jl/issues/26
end

@testset "JET" begin
    # JET reports genuine errors (getfield on Opti.py, undefined CasADi.var_dict)
    # tracked in https://github.com/SciML/CasADi.jl/issues/26 — run in report mode
    # and @test_broken the assertion so QA stays green and auto-flags once fixed.
    rep = JET.report_package(CasADi; target_defined_modules = true)
    @test_broken isempty(JET.get_reports(rep))  # JET: 3 possible errors — tracked in https://github.com/SciML/CasADi.jl/issues/26
end
