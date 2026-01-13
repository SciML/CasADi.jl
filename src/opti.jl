struct Opti
    py::Py
end

struct OptiSol
    py::Py
end

function Opti()
    return Opti(casadi.Opti())
end

function variable!(opti::Opti, dims...)
    return MX(opti.py._variable(dims...))
end

function parameter!(opti::Opti, dims...)
    return MX(opti.py._parameter(dims...))
end

function set_value!(opti::Opti, p::MX, val)
    return opti.py.set_value(p, val)
end

function set_initial!(opti::Opti, x::MX, val)
    return opti.py.set_initial(x, val)
end

function subject_to!(opti::Opti, expr::MX)
    return opti.py._subject_to(expr)
end

function minimize!(opti::Opti, expr::MX)
    return opti.py.minimize(expr)
end

function solver!(opti::Opti, solver::String, plugin_options::Dict = Dict(), solver_options::Dict = Dict())
    for (k, v) in solver_options
        v isa Dict && (solver_options[k] = PyDict(v))
    end
    return opti.py.solver(solver, PyDict(plugin_options), PyDict(solver_options))
end

function solve!(opti::Opti)
    psol = opti.py.solve()
    return OptiSol(psol)
end

function value(sol::OptiSol, expr::MX)
    vals = pyconvert(Any, sol.py.value(expr))
    return to_julia(MX(vals))
end

function debug_value(opti::Opti, expr::MX)
    vals = pyconvert(Any, opti.py.debug.value(expr))
    return to_julia(MX(vals))
end

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
