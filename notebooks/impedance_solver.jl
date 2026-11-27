### A Pluto.jl notebook ###
# v1.1.0

using Markdown
using InteractiveUtils

# ╔═╡ c19d01a2-2202-4740-9e61-c5c24a46f619
begin
    import Pkg
    Pkg.activate(@__DIR__)
    Pkg.instantiate()

    using Revise
    using LumpedNetworks
end

# ╔═╡ 49f01d42-ed1f-46e8-b780-1ef1e13ae9b2
begin
    using Unitful
    using ForwardDiff
    using NonlinearSolve
    using ADTypes: AutoForwardDiff
end

# ╔═╡ 57569dca-10b4-4c2e-9e83-ba580467bd0b
md"""
Let's solve for an L network that matches a 10Ω load to 50Ω at 3MHz.
"""

# ╔═╡ c7d60b12-47ab-4336-8eee-9e5d7e462aa0
function network_L(
        L::Unitful.Inductance,
        C::Unitful.Capacitance,
        input_node::Int64,
        output_node::Int64,
        ground_node::Int64,
    )
    c = Circuit()
    add!(c, input_node => output_node, L)
    add!(c, input_node => ground_node, C)

    return c
end

# ╔═╡ 725b16ec-3118-4bfb-92d9-3b4f6ef3d0b0
# Problem setup parameters
begin
    const input_node = 1
    const output_node = 2
    const ground_node = 3

    const f_match = 3.0u"MHz"
    const r_load = 10.0u"Ω"
    const r_target = 50.0u"Ω"
    const L_scale = 1.0u"μH"
    const C_scale = 1.0u"nF"
end;

# ╔═╡ ba825c34-d68a-4767-88ec-cb191ef7119e
function loaded_L(
        L::Unitful.Inductance,
        C::Unitful.Capacitance,
        R::Unitful.ElectricalResistance,
    )
    Lnetwork = network_L(L, C, input_node, output_node, ground_node)
    return add!(Lnetwork, output_node => ground_node, R)
end

# ╔═╡ edbc1a4e-a683-40df-8898-93ae41f004d0
# Random guess
guess = loaded_L(1u"μH", 1u"nF", r_load)

# ╔═╡ f4636cdc-6682-4fa6-b8ab-482dd2b38ba2
Z_guess = impedance(f_match, guess, input_node, ground_node)

# ╔═╡ af18b487-8ebc-48ed-a935-044cc5ba0761
abs(Z_guess), rad2deg(angle(Z_guess))

# ╔═╡ 8bb1e054-d10a-4330-a5ed-817b932174c0
md"""
## Solve for the component values

The circuit is linear in voltage and current, but its input impedance is nonlinear
in the component values. We solve two real equations: the input resistance must be
50Ω and its reactance must be zero.

Use dimensionless log parameters, `L = L_scale * exp(x[1])` and
`C = C_scale * exp(x[2])`, to keep both components positive. Dividing the complex
impedance error by `r_target` also makes the residual dimensionless.

`TrustRegion` uses an automatically differentiated Jacobian via `AutoForwardDiff()`.
Each residual evaluation builds the circuit and calls the same nodal `impedance`
solver used above. No Hessian is required.
"""

# ╔═╡ f7920b04-5bcf-44e1-bfe0-10831540f75c
matching_components(x) = (L_scale * exp(x[1]), C_scale * exp(x[2]))

# ╔═╡ dc212c60-5d47-4499-af07-d0e88ec0752f
# ╠═╡ disabled = true
#=╠═╡
function matching_residual(x, p)
	L, C = matching_components(x)
	z = impedance(f_match, loaded_L(L, C, r_load), input_node, ground_node)
	error = ustrip((z - r_target) / r_target)
	return [real(error), imag(error)]
end
  ╠═╡ =#

# ╔═╡ 5e230319-66a5-4a7c-bb97-674d93c26726
function matching_residual(x, p)
    L, C = matching_components(x)
    z = impedance(f_match, loaded_L(L, C, r_load), input_node, ground_node)
    Γ = (z - r_target) / (z + r_target)
    return [real(Γ), imag(Γ)]
end

# ╔═╡ 2f357142-9015-4bca-986c-825ec68304a5
# x = [0, 0] starts at L_scale = 1μH and C_scale = 1nF.
matching_problem = NonlinearProblem(matching_residual, zeros(2))

# ╔═╡ 4f769059-0d5b-4934-9454-4b32daa62c8c
matching_solution = solve(
    matching_problem,
    TrustRegion(; autodiff = AutoForwardDiff());
    abstol = 1.0e-10,
    reltol = 1.0e-10,
    maxiters = 100,
)

# ╔═╡ 7d3865d1-4d81-47e4-bbd9-4fe6a3a8074f
begin
    L_match, C_match = matching_components(matching_solution.u)
    Z_match = impedance(f_match, loaded_L(L_match, C_match, r_load), input_node, ground_node)
    (;
        L_match, C_match, Z_match,
        residual = matching_residual(matching_solution.u, nothing),
        retcode = matching_solution.retcode,
    )
end

# ╔═╡ aef06d0a-3936-4462-bd15-bea351494a85
md"""
For this ideal network, the analytical values are approximately **1.06103μH** and
**2.12207nF**, giving an input impedance of **50 + 0im Ω** at 3MHz.

The Jacobian below has one row for each residual (real and imaginary) and one
column for each log parameter (`x[1]` and `x[2]`).
"""

# ╔═╡ 28e83fcf-1d7d-4aaa-8f94-57cdc722abc9
J_match = ForwardDiff.jacobian(
    x -> matching_residual(x, nothing), matching_solution.u,
)

# ╔═╡ Cell order:
# ╠═c19d01a2-2202-4740-9e61-c5c24a46f619
# ╠═49f01d42-ed1f-46e8-b780-1ef1e13ae9b2
# ╠═57569dca-10b4-4c2e-9e83-ba580467bd0b
# ╠═c7d60b12-47ab-4336-8eee-9e5d7e462aa0
# ╠═725b16ec-3118-4bfb-92d9-3b4f6ef3d0b0
# ╠═ba825c34-d68a-4767-88ec-cb191ef7119e
# ╠═edbc1a4e-a683-40df-8898-93ae41f004d0
# ╠═f4636cdc-6682-4fa6-b8ab-482dd2b38ba2
# ╠═af18b487-8ebc-48ed-a935-044cc5ba0761
# ╠═8bb1e054-d10a-4330-a5ed-817b932174c0
# ╠═f7920b04-5bcf-44e1-bfe0-10831540f75c
# ╠═dc212c60-5d47-4499-af07-d0e88ec0752f
# ╠═5e230319-66a5-4a7c-bb97-674d93c26726
# ╠═2f357142-9015-4bca-986c-825ec68304a5
# ╠═4f769059-0d5b-4934-9454-4b32daa62c8c
# ╠═7d3865d1-4d81-47e4-bbd9-4fe6a3a8074f
# ╠═aef06d0a-3936-4462-bd15-bea351494a85
# ╠═28e83fcf-1d7d-4aaa-8f94-57cdc722abc9
