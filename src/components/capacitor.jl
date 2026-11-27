struct Capacitor{T <: Unitful.Capacitance} <: Component
    C::T
    a::Int; b::Int
end

Capacitor(C::T, a, b) where {T <: Unitful.Capacitance} = Capacitor{T}(C, a, b)

impedance(f::Unitful.Frequency, comp::Capacitor) = impedance(f, comp, comp.C)

function impedance(
        f::Unitful.Frequency,
        ::Capacitor,
        C::Unitful.Capacitance
    )
    return uconvert(u"Ω", 1 / (im * (2π * f) * C))
end
