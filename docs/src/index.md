# CasADi.jl

CasADi.jl provides Julia wrappers around the Python CasADi package for symbolic
expressions, solver construction, and the CasADi Opti stack.

```@contents
Pages = ["api.md"]
Depth = 2
```

## Example

```julia
using CasADi

x = SX("x")
y = SX("y")
f = (1 - x)^2 + 100 * (y - x^2)^2

solver = nlpsol(
    "solver",
    "ipopt",
    Dict("x" => vcat([x; y]), "f" => f),
    Dict("ipopt" => Dict("print_level" => 0), "print_time" => false),
)

solution = solve(solver; x0 = [0.0, 0.0])
```

See the [API](@ref) page for the public interface.
