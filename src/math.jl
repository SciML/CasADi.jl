## Unary operations
-(x::C) where {C <: CasadiSymbolicObject} = C(casadi.minus(0, x))
Base.sqrt(x::T) where {T <: CasadiSymbolicObject} = T(casadi.sqrt(x))
Base.sin(x::T) where {T <: CasadiSymbolicObject} = T(casadi.sin(x))
Base.cos(x::T) where {T <: CasadiSymbolicObject} = T(casadi.cos(x))
Base.sincos(x::T) where {T <: CasadiSymbolicObject} = T(sin(x)), T(cos(x))
Base.sinc(x::T) where {T <: CasadiSymbolicObject} = T(sin(x) / x)
Base.abs(x::T) where {T <: CasadiSymbolicObject} = T(casadi.fabs(x))
Base.exp(x::T) where {T <: CasadiSymbolicObject} = T(casadi.exp(x))

function Base.sum(x::T; dims = :) where {T <: CasadiSymbolicObject}
    if dims == 1
        T(casadi.sum1(x))
    elseif dims == 2
        T(casadi.sum2(x))
    elseif dims == (:)
        T(casadi.sum(x))
    else
        error("invalid dims for sum.")
    end
end

# NaNMath

## Binary operations
function +(x::C, y::Real) where {C <: CasadiSymbolicObject}
    C(casadi.plus(x, _float_if_irrational(y)))
end
function -(x::C, y::Real) where {C <: CasadiSymbolicObject}
    C(casadi.minus(x, _float_if_irrational(y)))
end
function /(x::C, y::Real) where {C <: CasadiSymbolicObject}
    C(casadi.mrdivide(x, _float_if_irrational(y)))
end
function ^(x::C, y::Real) where {C <: CasadiSymbolicObject}
    C(casadi.power(x, _float_if_irrational(y)))
end
function ^(x::C, y::Integer) where {C <: CasadiSymbolicObject}
    C(casadi.power(x, _float_if_irrational(y)))
end
function \(x::C, y::Real) where {C <: CasadiSymbolicObject}
    C(casadi.solve(x, _float_if_irrational(y)))
end
function ×(x::C, y::Real) where {C <: CasadiSymbolicObject}
    C(casadi.cross(x, _float_if_irrational(y)))
end

_float_if_irrational(x::Real) = x isa Irrational ? float(x) : x

function *(x::C, y::Real) where {C <: CasadiSymbolicObject}
    v = if size(x, 2) == size(y, 1)
        casadi.mtimes(x, _float_if_irrational(y))
    else
        casadi.times(x, _float_if_irrational(y))
    end
    C(v)
end

*(x::AbstractArray{<:Real}, y::C) where {C <: CasadiSymbolicObject} = C(x) * y
*(x::C, y::AbstractArray{<:Real}) where {C <: CasadiSymbolicObject} = x * C(y)

function >=(x::C, y::Real) where {C <: CasadiSymbolicObject}
    C(casadi.ge(x, _float_if_irrational(y)))
end
function >(x::C, y::Real) where {C <: CasadiSymbolicObject}
    C(casadi.gt(x, _float_if_irrational(y)))
end
function <=(x::C, y::Real) where {C <: CasadiSymbolicObject}
    C(casadi.le(x, _float_if_irrational(y)))
end
function <(x::C, y::Real) where {C <: CasadiSymbolicObject}
    C(casadi.lt(x, _float_if_irrational(y)))
end
function ==(x::C, y::Real) where {C <: CasadiSymbolicObject}
    C(casadi.eq(x, _float_if_irrational(y)))
end

function Base.isequal(x::C, y::C) where {C <: CasadiSymbolicObject}
    pyconvert(Bool, casadi.is_equal(x, y))
end
Base.iszero(x::C) where {C <: CasadiSymbolicObject} = pyconvert(Bool, x.x.is_zero())

## Symbolic substitution
function substitute(ex::Union{C, AbstractVector{C}, AbstractMatrix{C}},
        vars, vals) where {C <: CasadiSymbolicObject}
    v = if (vars isa AbstractMatrix{C} && vals isa AbstractMatrix) ||
           (vars isa AbstractVector{C}) || (vars isa C && vals isa Number)
        casadi.substitute(C(ex), C(vars), C(vals))
    else
        error()
    end
    C(v)
end
