"""
    Opti()

Julia wrapper for CasADi's `Opti` optimization stack.

Use an `Opti` object to create decision variables and parameters, add
constraints, set an objective, configure a solver, and solve the optimization
problem with [`solve!`](@ref).

# Examples

```julia
using CasADi

opti = Opti()
x = variable!(opti)
y = variable!(opti)
minimize!(opti, (y - x^2)^2)
subject_to!(opti, x^2 + y^2 == 1)
solver!(opti, "ipopt")
sol = solve!(opti)
value(sol, x)
```
"""
struct Opti
    py::Py
end

struct OptiSol
    py::Py
end

function Opti()
    return Opti(casadi.Opti())
end

"""
    variable!(opti::Opti, dims...)

Create a CasADi `MX` decision variable in `opti`.

Pass no dimensions for a scalar variable, one dimension for a vector, or two
dimensions for a matrix.

# Examples

```julia
using CasADi

opti = Opti()
x = variable!(opti)
u = variable!(opti, 3)
X = variable!(opti, 2, 2)
```
"""
function variable!(opti::Opti, dims...)
    return MX(opti.py._variable(dims...))
end

"""
    parameter!(opti::Opti, dims...)

Create a CasADi `MX` parameter in `opti`.

Parameters are symbolic inputs whose numeric values can be assigned with
[`set_value!`](@ref) before solving.

# Examples

```julia
using CasADi

opti = Opti()
p = parameter!(opti)
set_value!(opti, p, 2.0)
```
"""
function parameter!(opti::Opti, dims...)
    return MX(opti.py._parameter(dims...))
end

"""
    set_value!(opti::Opti, p::MX, val)

Set the numeric value of parameter `p` in `opti`.

# Examples

```julia
using CasADi

opti = Opti()
p = parameter!(opti)
set_value!(opti, p, 1.0)
```
"""
function set_value!(opti::Opti, p::MX, val)
    return opti.py.set_value(p, val)
end

"""
    set_initial!(opti::Opti, x::MX, val)

Set the initial guess for decision variable `x` in `opti`.

# Examples

```julia
using CasADi

opti = Opti()
x = variable!(opti)
set_initial!(opti, x, 0.5)
```
"""
function set_initial!(opti::Opti, x::MX, val)
    return opti.py.set_initial(x, val)
end

"""
    subject_to!(opti::Opti, expr::MX)

Add constraint expression `expr` to `opti`.

The expression is usually built from `MX` variables and relational operators.

# Examples

```julia
using CasADi

opti = Opti()
x = variable!(opti)
subject_to!(opti, x >= 0)
```
"""
function subject_to!(opti::Opti, expr::MX)
    return opti.py._subject_to(expr)
end

"""
    minimize!(opti::Opti, expr::MX)

Set the scalar objective expression minimized by `opti`.

# Examples

```julia
using CasADi

opti = Opti()
x = variable!(opti)
minimize!(opti, (x - 1)^2)
```
"""
function minimize!(opti::Opti, expr::MX)
    return opti.py.minimize(expr)
end

"""
    solver!(opti::Opti, solver::String, plugin_options::Dict = Dict(), solver_options::Dict = Dict())

Configure the CasADi solver plugin used by `opti`.

Nested dictionaries in `solver_options` are converted to Python dictionaries
before calling CasADi.

# Examples

```julia
using CasADi

opti = Opti()
solver!(opti, "ipopt", Dict(), Dict("ipopt" => Dict("print_level" => 0)))
```
"""
function solver!(opti::Opti, solver::String, plugin_options::Dict = Dict(), solver_options::Dict = Dict())
    for (k, v) in solver_options
        v isa Dict && (solver_options[k] = PyDict(v))
    end
    return opti.py.solver(solver, PyDict(plugin_options), PyDict(solver_options))
end

"""
    solve!(opti::Opti)

Solve the optimization problem stored in `opti` and return an internal solution
object accepted by [`value`](@ref).

# Examples

```julia
using CasADi

opti = Opti()
x = variable!(opti)
minimize!(opti, (x - 1)^2)
solver!(opti, "ipopt")
sol = solve!(opti)
value(sol, x)
```
"""
function solve!(opti::Opti)
    psol = opti.py.solve()
    return OptiSol(psol)
end

"""
    value(sol, expr::MX)

Evaluate expression `expr` at a solution returned by [`solve!`](@ref).

The result is converted to a Julia scalar, vector, or matrix with
[`to_julia`](@ref).

# Examples

```julia
using CasADi

opti = Opti()
x = variable!(opti)
minimize!(opti, (x - 1)^2)
solver!(opti, "ipopt")
sol = solve!(opti)
x_value = value(sol, x)
```
"""
function value(sol::OptiSol, expr::MX)
    vals = pyconvert(Any, sol.py.value(expr))
    return to_julia(MX(vals))
end

function debug_value(opti::Opti, expr::MX)
    vals = pyconvert(Any, opti.py.debug.value(expr))
    return to_julia(MX(vals))
end

"""
    return_status(opti::Opti)

Return CasADi's solver status string for `opti`.

# Examples

```julia
using CasADi

opti = Opti()
x = variable!(opti)
minimize!(opti, (x - 1)^2)
solver!(opti, "ipopt")
sol = solve!(opti)
return_status(opti)
```
"""
function return_status(opti::Opti)
    return pyconvert(String, opti.py.return_status())
end

function Base.copy(opti::Opti)
    return Opti(opti.py.copy())
end

function Base.getproperty(opti::Opti, sym::Symbol)
    return if sym == :x
        MX(getfield(opti, :py).x)
    elseif sym == :p
        MX(getfield(opti, :py).y)
    elseif sym == :nx
        pyconvert(Int, getfield(opti, :py).nx)
    elseif sym == :np
        pyconvert(Int, getfield(opti.py).np)
    elseif sym == :ng
        pyconvert(Int, getfield(opti.py).ng)
    elseif sym == :py
        getfield(opti, :py)
    else
        error("Cannot access field $sym of Opti object; please use the corresponding CasADi.jl API function (e.g. variable! instead of opti.variable). If something is missed here please open an issue.")
    end
end
