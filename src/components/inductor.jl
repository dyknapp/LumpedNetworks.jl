struct Inductor{T <: Unitful.Inductance} <: Component
    L::T
    a::Int; b::Int
end

Inductor(L::T, a, b) where {T <: Unitful.Inductance} = Inductor{T}(L, a, b)

impedance(f::Unitful.Frequency, comp::Inductor) = impedance(f, comp, comp.L)

function impedance(
        f::Unitful.Frequency,
        ::Inductor,
        L::Unitful.Inductance
    )
    return uconvert(u"Ω", im * (2π * f) * L)
end
