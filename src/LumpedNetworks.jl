module LumpedNetworks

# dependencies
using Unitful # keeping track of dimensions nicely
using Graphs  # circuit topology bookkeeping and algorithms


include("interfaces/component.jl")

include("components/capacitor.jl")
include("components/inductor.jl")
include("components/resistor.jl")
include("components/convenience.jl")

include("circuit/circuit.jl")
include("circuit/impedance.jl")


export Component
export Capacitor, Inductor, Resistor

export Circuit
export add!
export impedance

end
