struct CasadiFunction
    py::Py
end

"""
    nlpsol(name::String, solver::String, var_dict::Dict, solver_options::Dict)

Create a CasADi nonlinear-programming solver and return a `CasadiFunction`
wrapper.

`var_dict` is passed to `casadi.nlpsol` and typically contains entries such as
`"x"` for decision variables and `"f"` for the objective. Nested dictionaries in
`solver_options` are converted to Python dictionaries before calling CasADi.

# Arguments

- `name`: CasADi name assigned to the solver instance.
- `solver`: installed CasADi NLP plugin name, such as `"ipopt"`.
- `var_dict`: CasADi NLP definition, including at least `"x"` and `"f"`.
- `solver_options`: plugin and CasADi options.

# Examples

```julia
using CasADi

x = SX("x")
problem = Dict("x" => x, "f" => (x - 1)^2)
solver = nlpsol("solver", "ipopt", problem, Dict("print_time" => false))
solve(solver; x0 = [0.0])
```
"""
function nlpsol(name::String, solver::String, var_dict::Dict, solver_options::Dict)
    opts = Dict{String, Any}(k => (v isa Dict ? PyDict(v) : v) for (k, v) in solver_options)
    return CasadiFunction(casadi.nlpsol(name, solver, PyDict(var_dict), PyDict(opts)))
end

"""
    qpsol(name::String, solver::String, var_dict::Dict, solver_options::Dict)

Create a CasADi quadratic-programming solver and return a `CasadiFunction`
wrapper.

Arguments are forwarded to `casadi.qpsol`, with nested solver option
dictionaries converted to Python dictionaries.

# Arguments

- `name`: CasADi name assigned to the solver instance.
- `solver`: installed CasADi QP plugin name, such as `"qpoases"`.
- `var_dict`: high-level CasADi QP definition with `"x"`, `"f"`, and optional `"g"`.
- `solver_options`: plugin and CasADi options.

# Examples

```julia
using CasADi

x = SX("x")
y = SX("y")
problem = Dict("x" => vcat([x, y]), "f" => x^2 + y^2, "g" => x + y - 10)
solver = qpsol("solver", "qpoases", problem, Dict())
```
"""
function qpsol(name::String, solver::String, var_dict::Dict, solver_options::Dict)
    opts = Dict{String, Any}(k => (v isa Dict ? PyDict(v) : v) for (k, v) in solver_options)
    return CasadiFunction(casadi.qpsol(name, solver, PyDict(var_dict), PyDict(opts)))
end

"""
casadi.integrator
"""
function integrator()
    return CasadiFunction(casadi.integrator())
end

"""
    solve(solver::CasadiFunction; x0::Vector)

Solve a CasADi function created by [`nlpsol`](@ref) or [`qpsol`](@ref).

The returned Python dictionary is converted to a Julia `Dict`; numeric CasADi
values are converted with [`to_julia`](@ref).

# Arguments

- `solver`: solver created by [`nlpsol`](@ref) or [`qpsol`](@ref).

# Keyword Arguments

- `x0`: required initial decision-variable value.

# Examples

```julia
using CasADi

x = SX("x")
solver = nlpsol("solver", "ipopt", Dict("x" => x, "f" => (x - 1)^2), Dict())
solution = solve(solver; x0 = [0.0])
solution["x"]
```
"""
function solve(solver::CasadiFunction; x0::Vector = error("Must provide x0."))
    psol = solver.py(x0 = x0)
    sol = pyconvert(Dict, psol)
    jsol = Dict()
    for (k, v) in sol
        val = sol[k]
        jsol[k] = to_julia(DM(Py(val)))
    end
    return jsol
end
