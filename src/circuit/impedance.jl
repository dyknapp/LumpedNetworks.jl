#=
- The general approach:
We put a 1A test current between nodes a and b.
Ohm's law gives I = Y V for admittance (matrix) Y.
We can solve for the voltage between nodes a and b, and the impedance is just V / I = V / 1A.
V is obtained by solving the linear system V = Y \ I.
Y is actually singular because Kirchoff's equations tell us that the nodes have zero net current.
We can fix this by setting a ground reference, which is just node b in this simple case.
We remove node b by removing its row and column giving an (n-1)x(n-1) invertible system.
=#
function impedance(f, circ::Circuit, a::Int, b::Int)
    # Find the last node
    n = maximum(max(c.a, c.b) for c in circ.components)

    # Promote all component admittances so derivatives (e.g. ForwardDiff dual numbers) survive even when only a later component is differentiated.
    admittances = [ustrip(u"S", 1 / impedance(f, c)) for c in circ.components]
    T = mapreduce(typeof, promote_type, admittances)
    Y = zeros(T, n, n)

    # Iterate over components and scatter admittances into Y
    for (c, y) in zip(circ.components, admittances)
        y = ustrip(u"S", 1 / impedance(f, c))
        i, j = c.a, c.b
        Y[i, i] += y;  Y[j, j] += y
        Y[i, j] -= y;  Y[j, i] -= y
    end

    # keep stores the indices of all nodes except for b
    keep = setdiff(1:n, b)

    # We are injecting the 1A test current into node a.
    # By conservation of charge, all current must be flowing out of node b.
    I = zeros(T, n); I[a] = one(T)

    # Solve the linear system
    v = Y[keep, keep] \ I[keep]

    # Return with a unit conversion to ohms because of the 1A injection.
    return v[findfirst(==(a), keep)] * u"Ω"
end
