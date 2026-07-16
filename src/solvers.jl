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
    for (k, v) in solver_options
        v isa Dict && (solver_options[k] = PyDict(v))
    end
    return CasadiFunction(casadi.nlpsol(name, solver, PyDict(var_dict), PyDict(solver_options)))
end

"""
    qpsol(name::String, solver::String, vardict::Dict, solver_options::Dict)

Create a CasADi quadratic-programming solver and return a `CasadiFunction`
wrapper.

Arguments are forwarded to `casadi.qpsol`, with nested solver option
dictionaries converted to Python dictionaries.
"""
function qpsol(name::String, solver::String, vardict::Dict, solver_options::Dict)
    for (k, v) in solver_options
        v isa Dict && (solver_options[k] = PyDict(v))
    end
    return CasadiFunction(casadi.qpsol(name, solver, PyDict(var_dict), PyDict(solver_options)))
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

# Examples

```julia
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
