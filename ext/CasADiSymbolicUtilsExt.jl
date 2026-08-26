module CasADiSymbolicUtilsExt

using CasADi: CasadiSymbolicObject
import SymbolicUtils

function SymbolicUtils.Code.create_array(
        ::Type{T}, ::Nothing, ::Val{1}, ::Val{dims}, elems...
    ) where {T <: CasadiSymbolicObject, dims}
    return T([elems...])
end

function SymbolicUtils.Code.create_array(
        ::Type{T}, output_eltype, ::Val{1}, ::Val{dims}, elems...
    ) where {T <: CasadiSymbolicObject, dims}
    return T(output_eltype[elems...])
end

end
