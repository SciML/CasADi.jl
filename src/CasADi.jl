module CasADi

import PythonCall
using PythonCall: Py, PyDict, pyconvert, pygetitem, pyimport, pyrowlist,
    pystr,
    pysetitem

import Base: convert, getproperty, hash, length, promote_rule, size, vcat
import Base: +, -, *, /, \, ^
import Base: >, >=, <, <=, ==
import LinearAlgebra: symmetric, symmetric_type, ×

export CasadiSymbolicObject, SX, MX, DM
export casadi, to_julia, substitute
export nlpsol, qpsol, solve!, solve
export Opti, variable!, subject_to!, minimize!, parameter!, set_initial!, set_value!,
    solver!, value, return_status

include("types.jl")
include("math.jl")
include("array_utils.jl")
include("opti.jl")
include("solvers.jl")

##################################################

"""
    casadi

PythonCall handle for the imported Python `casadi` module.

Most users should prefer the Julia wrappers such as [`SX`](@ref), [`MX`](@ref),
[`DM`](@ref), [`nlpsol`](@ref), and [`Opti`](@ref). Access `casadi` directly
when a lower-level Python CasADi function is not wrapped yet.

# Examples

```julia
using CasADi

py_x = casadi.SX.sym("x")
SX(py_x)
```
"""
const casadi = PythonCall.pynew()
function __init__()
    return PythonCall.pycopy!(casadi, pyimport("casadi"))
end

using PrecompileTools: @compile_workload, @setup_workload

@setup_workload begin
    casadi_workload = PythonCall.pyimport("casadi")
    PythonCall.pycopy!(casadi, casadi_workload)
    @compile_workload begin
        x = SX("x")
        expr = x^2 + 2x + 1
        substitute(expr, x, 1)
        to_julia(DM([1.0, 2.0]))
        opti = Opti()
        z = variable!(opti)
        subject_to!(opti, z >= 0)
        minimize!(opti, z^2)
    end
end

end # module
