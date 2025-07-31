struct CasadiFunction
    py::Py
end

"""
casadi.nlpsol
"""
function nlpsol(name::String, solver::String, var_dict::Dict, solver_options::Dict)
    for (k, v) in solver_options
        v isa Dict && (solver_options[k] = PyDict(v))
    end
    CasadiFunction(casadi.nlpsol(name, solver, PyDict(var_dict), PyDict(solver_options)))
end

"""
casadi.qpsol
"""
function qpsol(name::String, solver::String, vardict::Dict, solver_options::Dict)
    for (k, v) in solver_options
        v isa Dict && (solver_options[k] = PyDict(v))
    end
    CasadiFunction(casadi.qpsol(name, solver, PyDict(var_dict), PyDict(solver_options)))
end

"""
casadi.integrator
"""
function integrator()
    CasadiFunction(casadi.integrator())
end

"""
Solve a casadi problem, returns a Julia dictionary.
"""
function solve(solver::CasadiFunction; x0::Vector = error("Must provide x0."))
    psol = solver.py(x0 = x0)
    sol = pyconvert(Dict, psol)
    jsol = Dict()
    for (k, v) in sol
        val = sol[k]
        jsol[k] = to_julia(DM(Py(val)))
    end
    jsol
end
