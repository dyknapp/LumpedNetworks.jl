struct Circuit
    components::Vector{Component}

    function Circuit()
        return new(Component[])
    end
end

function Base.push!(circ::Circuit, c::Component)
    c.a == c.b && throw(ArgumentError("component shorted to itself"))
    push!(circ.components, c)
    return circ
end

# netlist-like alias
add!(circ::Circuit, nodes::Pair{Int, Int}, val) =
    push!(circ, component(val, nodes.first, nodes.second))

"""
    SimpleGraph(circ::Circuit)

Convert positive integer node labels directly to graph vertex indices. Labels
must be contiguous from one to avoid extra isolated vertices. For impedance
evaluation with arbitrary labels (including zero), use `prepare_impedance`.
"""
Graphs.SimpleGraph(circ::Circuit) =
    SimpleGraph(Edge.([(c.a, c.b) for c in circ.components]))
