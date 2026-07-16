module CasADi

using PythonCall
using SymbolicUtils

import Base: convert, getproperty, hcat, length, promote_rule, show, size, vcat, hash
import Base: +, -, *, /, \, ^
import Base: >, >=, <, <=, ==
import LinearAlgebra: ×

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
"""
const casadi = PythonCall.pynew()
function __init__()
    return PythonCall.pycopy!(casadi, pyimport("casadi"))
end

end # module
