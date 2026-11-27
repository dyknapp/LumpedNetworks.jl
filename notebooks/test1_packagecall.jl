### A Pluto.jl notebook ###
# v1.1.0

using Markdown
using InteractiveUtils

# ╔═╡ 7380b3d0-ea4a-11f1-80e8-f5fa647f37a8
begin
    import Pkg
    Pkg.activate(@__DIR__)
    Pkg.instantiate()

    using Revise
    using LumpedNetworks
end

# ╔═╡ 8e0e0314-ef7f-4308-bce5-7c6872173d17
begin
    using Plots
    using Unitful
end

# ╔═╡ 11ad2f17-4306-4f66-a47a-7f86a48d3d7f
test_circuit = begin
    c = Circuit()
    add!(c, 1 => 2, 50u"Ω")
    add!(c, 2 => 3, 1u"μH")
    add!(c, 3 => 4, 1u"Ω")
    add!(c, 2 => 4, 20u"nF")
    c
end

# ╔═╡ 794ab0a3-9d45-4c2d-a7bd-130bef00a8e0
f_range = [f * 1u"Hz" for f in exp10.(LinRange(5.5, 6.5, 1024))]

# ╔═╡ 0bca6bda-47d1-420e-88fa-8e74a1c666c6
plot(
    uconvert.(u"MHz", f_range),
    abs.(impedance.(f_range, Ref(test_circuit), 2, 4)),
    xscale = :log10,
)

# ╔═╡ Cell order:
# ╠═7380b3d0-ea4a-11f1-80e8-f5fa647f37a8
# ╠═8e0e0314-ef7f-4308-bce5-7c6872173d17
# ╠═11ad2f17-4306-4f66-a47a-7f86a48d3d7f
# ╠═794ab0a3-9d45-4c2d-a7bd-130bef00a8e0
# ╠═0bca6bda-47d1-420e-88fa-8e74a1c666c6
