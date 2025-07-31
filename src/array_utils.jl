## Indexing
function Base.getindex(x::T, j::Union{
        Int, UnitRange{Int}, Colon}) where {T <: CasadiSymbolicObject}
    T(pygetitem(x.x, (1:length(x))[j] .- 1))
end

function Base.getindex(x::T, j1::Union{Int, UnitRange{Int}, Colon},
        j2::Union{Int, UnitRange{Int}, Colon}) where {T <: CasadiSymbolicObject}
    (m, n) = size(x)
    T(pygetitem(x.x, (
        (1:m)[j1 isa Int ? (j1:j1) : j1] .- 1, (1:n)[j2 isa Int ? (j2:j2) : j2] .- 1)))
end

function Base.setindex!(x::CasadiSymbolicObject, v::Number, j::Union{
        Int, UnitRange{Int}, Colon})
    pysetitem(x.x, (1:length(x))[j isa Int ? (j:j) : j] .- 1, v)
    x
end

function Base.setindex!(
        x::CasadiSymbolicObject,
        v::Number,
        j1::Union{Int, UnitRange{Int}, Colon},
        j2::Union{Int, UnitRange{Int}, Colon}
)
    (m, n) = size(x)
    J1 = j1 isa Int ? (j1:j1) : j1
    J2 = j2 isa Int ? (j2:j2) : j2
    pysetitem(
        x.x, (
            (1:m)[j1 isa Int ? (j1:j1) : j1] .- 1, (1:n)[j2 isa Int ? (j2:j2) : j2] .- 1), v)
end

Base.lastindex(x::CasadiSymbolicObject) = length(x)
Base.lastindex(x::CasadiSymbolicObject, j::Int) = size(x, j)

## one, zero, zeros, ones
function Base.one(::Type{C}) where {C <: CasadiSymbolicObject}
    C(getproperty(casadi, Symbol(C)).eye(1))
end
function Base.one(x::C) where {C <: CasadiSymbolicObject}
    if size(x, 1) == size(x, 2)
        C(getproperty(casadi, Symbol(C)).eye(size(x, 1)))
    else
        throw(DimensionMismatch("multiplicative identity defined only for square matrices"))
    end
end

function Base.zero(::Type{C}) where {C <: CasadiSymbolicObject}
    C(getproperty(casadi, Symbol(C)).zeros())
end
function Base.zero(x::C) where {C <: CasadiSymbolicObject}
    C(getproperty(casadi, Symbol(C)).zeros(size(x)))
end

function Base.ones(::Type{C}, j::Integer) where {C <: CasadiSymbolicObject}
    C(getproperty(casadi, Symbol(C)).ones(j))
end
function Base.ones(::Type{C}, j1::Integer, j2::Integer) where {C <: CasadiSymbolicObject}
    C(getproperty(casadi, Symbol(C)).ones(j1, j2))
end

function Base.zeros(::Type{C}, j::Integer) where {C <: CasadiSymbolicObject}
    C(getproperty(casadi, Symbol(C)).zeros(j))
end
function Base.zeros(::Type{C}, j1::Integer, j2::Integer) where {C <: CasadiSymbolicObject}
    C(getproperty(casadi, Symbol(C)).zeros(j1, j2))
end

## Size related operations
Base.size(x::CasadiSymbolicObject) = pyconvert(Tuple, x.size())

function Base.size(x::C, j::Integer) where {C <: CasadiSymbolicObject}
    if j == 1
        return pyconvert(Int, x.size1())
    elseif j == 2
        return pyconvert(Int, x.size2())
    else
        throw(DimensionMismatch("arraysize: dimension out of range"))
    end
end
Base.length(x::C) where {C <: CasadiSymbolicObject} = pyconvert(Int, x.numel())

## Concatenations
Base.hcat(x::Vector{T}) where {T <: CasadiSymbolicObject} = T(casadi.hcat(x))
Base.vcat(x::Vector{T}) where {T <: CasadiSymbolicObject} = T(casadi.vcat(x))

## Matrix operations
Base.transpose(x::T) where {T <: CasadiSymbolicObject} = T(casadi.transpose(x))
Base.adjoint(x::CasadiSymbolicObject) = transpose(x)
function Base.repeat(x::T, counts::Integer...) where {T <: CasadiSymbolicObject}
    T(casadi.repmat(x, counts...))
end
function Base.reshape(x::T, t::Tuple{Int, Int}) where {T <: CasadiSymbolicObject}
    T(casadi.reshape(x, t))
end
Base.inv(x::T) where {T <: CasadiSymbolicObject} = T(casadi.inv(x))
Base.vec(x::T) where {T <: CasadiSymbolicObject} = T(casadi.vec(x))

# From vector to SX/MX
function Base.convert(::Type{T}, V::AbstractVector{T}) where {T <: CasadiSymbolicObject}
    T(casadi.vcat(pyrowlist(V)))
end

# From matrix to SX/MX
function Base.convert(::Type{T}, M::AbstractMatrix{T}) where {T <: CasadiSymbolicObject}
    T(casadi.blockcat(pyrowlist(M)))
end

# Convert SX/MX to vector
function Base.Vector(V::T) where {T <: CasadiSymbolicObject}
    v = pyconvert(Vector, casadi.vertsplit(V))
    v = map(el -> T(Py(el)), v)
end

# Convert SX/MX to Matrix{SX/MX}
function Base.Matrix(M::T) where {T <: CasadiSymbolicObject}
    m = casadi.blocksplit(M)
    m = reduce(vcat, pyconvert(Vector, m))
    m = map(el -> T(Py(el)), m)
    i, j = size(M)
    permutedims(reshape(m, (j, i)))
end

## Solve linear systems
function Base.:\(A::Matrix{C}, b::Vector{C}) where {C <: CasadiSymbolicObject}
    Vector(C(casadi.solve(C(A), C(b))))
end

function Base.:\(A::AbstractMatrix{C}, b::AbstractMatrix{N}) where {
        C <: CasadiSymbolicObject, N <: Number}
    Matrix(C(casadi.solve(C(A), C(b))))
end

function Base.:\(A::AbstractMatrix{N}, b::AbstractMatrix{C}) where {
        C <: CasadiSymbolicObject, N <: Number}
    Matrix(C(casadi.solve(C(A), C(b))))
end

function SymbolicUtils.Code.create_array(::Type{T}, ::Nothing, ::Val{1}, ::Val{dims},
        elems...) where {T <: CasadiSymbolicObject, dims}
    T([elems...])
end

function SymbolicUtils.Code.create_array(::Type{C}, T, ::Val{1}, ::Val{dims},
        elems...) where {C <: CasadiSymbolicObject, dims}
    C(T[elems...])
end
