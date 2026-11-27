struct Resistor{T <: Unitful.ElectricalResistance} <: Component
    R::T
    a::Int; b::Int
end

Resistor(R::T, a, b) where {T <: Unitful.ElectricalResistance} = Resistor{T}(R, a, b)

impedance(f::Unitful.Frequency, comp::Resistor) = impedance(f, comp, comp.R)

function impedance(
        f::Unitful.Frequency,
        ::Resistor,
        R::Unitful.ElectricalResistance
    )
    return R
end
