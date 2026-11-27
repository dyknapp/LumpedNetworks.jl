component(R::Unitful.ElectricalResistance, a, b) = Resistor(R, a, b)
component(L::Unitful.Inductance, a, b) = Inductor(L, a, b)
component(C::Unitful.Capacitance, a, b) = Capacitor(C, a, b)
component(Z::Unitful.Quantity) = component(Z, 0, 0)
