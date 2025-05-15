abstract type CasadiSymbolicObject <: Real end

struct SX <: CasadiSymbolicObject
    x::Py
end

struct MX <: CasadiSymbolicObject
    x::Py
end

struct DM <: CasadiSymbolicObject
    x::Py
end

PythonCall.Py(x::CasadiSymbolicObject) = x.x
PythonCall.pyconvert(::Type{T}, x::Py) where {T <: CasadiSymbolicObject} = T(x)

Base.show(io::IO, c::CasadiSymbolicObject) = print(io, pycall(pybuiltins.str, c.x))
_tonparr(a::AbstractArray) = Py(a).__array__()

## text/plain

function Base.getproperty(o::C, s::Symbol) where {C<:CasadiSymbolicObject}
    if s in fieldnames(C)
        getfield(o, s)
    else
        pyconvert(Any, getproperty(o.x, s))
    end
end

SX(x::T) where {T<:Irrational} = pyconvert(SX, casadi.SX(float(x)))
SX(x::T) where {T<:Number} = pyconvert(SX, casadi.SX(x))
SX(x::AbstractVecOrMat{SX}) = convert(SX, x)
SX(x::AbstractVecOrMat{T}) where {T<:Number} = pyconvert(SX, casadi.SX(_tonparr(x)))
SX(x::AbstractString) = pyconvert(SX, casadi.SX.sym(x))
SX(x::AbstractString, i1::Integer) = pyconvert(SX, casadi.SX.sym(x, i1))
SX(x::AbstractString, i1::Integer, i2::Integer) = pyconvert(SX, casadi.SX.sym(x, i1, i2))
SX(i1::Integer, i2::Integer) = pyconvert(SX, casadi.SX(i1, i2))

DM(x::T) where {T<:Irrational} = pyconvert(SX, casadi.DM(float(x)))
DM(x::T) where {T<:Number} = pyconvert(DM, casadi.DM(x))
DM(x::AbstractVecOrMat{DM}) = convert(DM, x)
DM(x::AbstractVecOrMat{T}) where {T<:Number} = pyconvert(DM, casadi.DM(_tonparr(x)))
DM(i1::Integer, i2::Integer) = pyconvert(DM, casadi.DM(i1, i2))

MX(x::T) where {T<:Irrational} = pyconvert(MX, casadi.MX(float(x)))
MX(x::T) where {T<:Number} = pyconvert(MX, casadi.MX(x))
MX(x::AbstractVecOrMat{MX}) = convert(MX, x)
MX(x::AbstractVecOrMat{T}) where {T<:Number} = pyconvert(MX, casadi.MX(_tonparr(x)))
MX(x::AbstractString) = pyconvert(MX, casadi.MX.sym(x))
MX(x::AbstractString, i1::Integer) = pyconvert(MX, casadi.MX.sym(x, i1))
MX(x::AbstractString, i1::Integer, i2::Integer) = pyconvert(MX, casadi.MX.sym(x, i1, i2))
MX(i1::Integer, i2::Integer) = pyconvert(MX, casadi.MX(i1, i2))

convert(::Type{C}, s::AbstractString) where {C<:CasadiSymbolicObject} = C(s)

## promote up to symbolic so that mathops work
promote_rule(::Type{T}, ::Type{S}) where {T<:CasadiSymbolicObject,S<:Real} = T
convert(::Type{Py}, s::CasadiSymbolicObject) = s.x

"""
Convert a numeric CasADi value to a numeric Julia value.
"""
function to_julia(x::CasadiSymbolicObject)
    vals = pyconvert(Vector, casadi.evalf(x).toarray())
    vals = reduce(vcat, vals; init = zeros(0))

    if size(x) == (1, 1)
        return pyconvert(Float64, vals[1][1])
    elseif size(x, 2) == 1
        return pyconvert(Vector{Float64}, vals)
    else
        i, j = size(x)
        vals = permutedims(reshape(vals, (j, i)))
    end
end

Base.hash(C::CasadiSymbolicObject, x::UInt) = hash(C.x, x)
