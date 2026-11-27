abstract type Component end

function impedance(
        f::Unitful.Frequency,
        comp::Component
    )::Unitful.ElectricalResistance
    error("Unimplemented")
end
