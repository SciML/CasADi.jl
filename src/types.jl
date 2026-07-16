"""
    CasadiSymbolicObject

Abstract supertype for Julia wrappers around CasADi symbolic and numeric objects.

Subtypes such as [`SX`](@ref), [`MX`](@ref), and [`DM`](@ref) hold the underlying
Python CasADi object and participate in Julia arithmetic by forwarding operations
to CasADi.
"""
abstract type CasadiSymbolicObject <: Real end

"""
    SX(x)
    SX(name::AbstractString)
    SX(name::AbstractString, n::Integer)
    SX(name::AbstractString, n::Integer, m::Integer)
    SX(n::Integer, m::Integer)

Wrapper for CasADi `SX` symbolic expressions.

Use `SX(name)` and its dimensioned forms to create scalar, vector, or matrix
symbolic variables. Numeric scalars and numeric vectors or matrices construct
constant `SX` values.

# Examples

```julia
using CasADi

x = SX("x")
v = SX("v", 3)
A = SX("A", 2, 2)
c = SX([1.0, 2.0, 3.0])
```
"""
struct SX <: CasadiSymbolicObject
    x::Py
end

"""
    MX(x)
    MX(name::AbstractString)
    MX(name::AbstractString, n::Integer)
    MX(name::AbstractString, n::Integer, m::Integer)
    MX(n::Integer, m::Integer)

Wrapper for CasADi `MX` symbolic expressions.

Use `MX(name)` and its dimensioned forms to create scalar, vector, or matrix
symbolic variables. Numeric scalars and numeric vectors or matrices construct
constant `MX` values.

# Examples

```julia
using CasADi

x = MX("x")
u = MX("u", 2)
M = MX("M", 2, 3)
```
"""
struct MX <: CasadiSymbolicObject
    x::Py
end

"""
    DM(x)
    DM(n::Integer, m::Integer)

Wrapper for CasADi dense numeric matrices.

Use `DM` for concrete numeric CasADi values. Numeric scalars and numeric vectors
or matrices construct populated `DM` values, while `DM(n, m)` constructs an
`n` by `m` CasADi dense matrix.

# Examples

```julia
using CasADi

a = DM(1.0)
v = DM([1.0, 2.0, 3.0])
Z = DM(2, 3)
```
"""
struct DM <: CasadiSymbolicObject
    x::Py
end

PythonCall.Py(x::CasadiSymbolicObject) = x.x
PythonCall.pyconvert(::Type{T}, x::Py) where {T <: CasadiSymbolicObject} = T(x)

Base.show(io::IO, c::CasadiSymbolicObject) = print(io, pycall(pybuiltins.str, c.x))
_tonparr(a::AbstractArray) = Py(a).__array__()

## text/plain

function Base.getproperty(o::C, s::Symbol) where {C <: CasadiSymbolicObject}
    return if s in fieldnames(C)
        getfield(o, s)
    else
        pyconvert(Any, getproperty(o.x, s))
    end
end

SX(x::T) where {T <: Irrational} = pyconvert(SX, casadi.SX(float(x)))
SX(x::T) where {T <: Number} = pyconvert(SX, casadi.SX(x))
SX(x::AbstractVecOrMat{SX}) = convert(SX, x)
SX(x::AbstractVecOrMat{T}) where {T <: Number} = pyconvert(SX, casadi.SX(_tonparr(x)))
SX(x::AbstractString) = pyconvert(SX, casadi.SX.sym(x))
SX(x::AbstractString, i1::Integer) = pyconvert(SX, casadi.SX.sym(x, i1))
SX(x::AbstractString, i1::Integer, i2::Integer) = pyconvert(SX, casadi.SX.sym(x, i1, i2))
SX(i1::Integer, i2::Integer) = pyconvert(SX, casadi.SX(i1, i2))

DM(x::T) where {T <: Irrational} = pyconvert(SX, casadi.DM(float(x)))
DM(x::T) where {T <: Number} = pyconvert(DM, casadi.DM(x))
DM(x::AbstractVecOrMat{DM}) = convert(DM, x)
DM(x::AbstractVecOrMat{T}) where {T <: Number} = pyconvert(DM, casadi.DM(_tonparr(x)))
DM(i1::Integer, i2::Integer) = pyconvert(DM, casadi.DM(i1, i2))

MX(x::T) where {T <: Irrational} = pyconvert(MX, casadi.MX(float(x)))
MX(x::T) where {T <: Number} = pyconvert(MX, casadi.MX(x))
MX(x::AbstractVecOrMat{MX}) = convert(MX, x)
MX(x::AbstractVecOrMat{T}) where {T <: Number} = pyconvert(MX, casadi.MX(_tonparr(x)))
MX(x::AbstractString) = pyconvert(MX, casadi.MX.sym(x))
MX(x::AbstractString, i1::Integer) = pyconvert(MX, casadi.MX.sym(x, i1))
MX(x::AbstractString, i1::Integer, i2::Integer) = pyconvert(MX, casadi.MX.sym(x, i1, i2))
MX(i1::Integer, i2::Integer) = pyconvert(MX, casadi.MX(i1, i2))

convert(::Type{C}, s::AbstractString) where {C <: CasadiSymbolicObject} = C(s)

## promote up to symbolic so that mathops work
promote_rule(::Type{T}, ::Type{S}) where {T <: CasadiSymbolicObject, S <: Real} = T
convert(::Type{Py}, s::CasadiSymbolicObject) = s.x

"""
    to_julia(x::CasadiSymbolicObject)

Evaluate a numeric CasADi object and convert it to a Julia scalar, vector, or
matrix of `Float64` values.

Scalar CasADi values return a `Float64`, column vectors return `Vector{Float64}`,
and other matrices return `Matrix{Float64}`.

# Examples

```julia
using CasADi

to_julia(DM(1.5))
to_julia(DM([1.0, 2.0]))
```
"""
function to_julia(x::CasadiSymbolicObject)
    mat = pyconvert(Matrix{Float64}, casadi.evalf(x).full())
    m, n = Base.size(mat)
    if m == 1 && n == 1
        return mat[1, 1]
    elseif n == 1
        return vec(mat)
    else
        return mat
    end
end

Base.hash(C::CasadiSymbolicObject, x::UInt) = hash(C.x, x)
