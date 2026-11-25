using LumpedNetworks
using Test
using Aqua
using JET

@testset "LumpedNetworks.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(LumpedNetworks)
    end
    @testset "Code linting (JET.jl)" begin
        JET.test_package(LumpedNetworks; target_defined_modules = true)
    end
    # Write your tests here.
end
