using BenchmarkTools
using CasADi

const SUITE = BenchmarkGroup()

SUITE["symbolic_sx"] = BenchmarkGroup()
SUITE["symbolic_sx"]["construct_scalar"] = @benchmarkable SX("x")
x = SX("x")
y = SX("y")
SUITE["symbolic_sx"]["construct_vector"] = @benchmarkable SX("v", 10)
expr = (x - 1)^2 + 100 * (y - x^2)^2
expr_1var = x^2 + 2x + 1
SUITE["symbolic_sx"]["rosenbrock_expr"] = @benchmarkable ($x - 1)^2 + 100 * ($y - $x^2)^2
SUITE["symbolic_sx"]["substitute"] = @benchmarkable to_julia(substitute($expr_1var, $x, 1))
SUITE["symbolic_sx"]["dm_convert"] = @benchmarkable to_julia(DM([1.0, 2.0, 3.0, 4.0]))

SUITE["nlpsol"] = BenchmarkGroup()
nlp = Dict("x" => vcat([x; y]), "f" => expr)
SUITE["nlpsol"]["construct_ipopt"] = @benchmarkable nlpsol(
    "S", "ipopt", $nlp,
    Dict("ipopt" => Dict(["print_level" => 0]), "verbose" => false)
)
solver = nlpsol(
    "S", "ipopt", nlp,
    Dict("ipopt" => Dict(["print_level" => 0]), "verbose" => false)
)
SUITE["nlpsol"]["solve_rosenbrock"] = @benchmarkable solve($solver, x0 = [0, 0])

SUITE["opti"] = BenchmarkGroup()
SUITE["opti"]["construct"] = @benchmarkable Opti()

function opti_problem()
    opti = Opti()
    a = variable!(opti)
    b = variable!(opti)
    minimize!(opti, (b - a^2)^2)
    subject_to!(opti, a^2 + b^2 == 1)
    subject_to!(opti, a + b >= 1)
    solver!(opti, "ipopt", Dict("verbose" => false), Dict("print_level" => 0))
    return opti
end

SUITE["opti"]["build_problem"] = @benchmarkable opti_problem()
opti_inst = opti_problem()
SUITE["opti"]["solve"] = @benchmarkable solve!($opti_inst)
