println("
#####################
#  Multi-Band Chem  #
#####################
")

##################
# INITIALISATION #
##################

tol = 1e-1

# Extract name of the current file. Will be used as code name for the simulation.
name_jl = last(splitpath(Base.source_path()))
name = first(split(name_jl,"."))


#################
# DEFINE SYSTEM #
#################

t_OS = [0.0 0.0; 0.0 0.0];
t_IS = [1.0 0.0; 0.0 1.0];
t = cat(t_OS,t_IS, dims=2)

U = [1.0 0.0; 0.0 1.0]
V = [0.0 0.0; 0.0 0.0]
u = cat(U,V,dims=2)

J = [0.0 0.0; 0.0 0.0]

μ = [0.5, 0.5]

bond_dim = 20;

model = hf.MBC_Sim(t, u, J, μ, 2.0, bond_dim; verbosity=0, code=name);


###############
# GROUNDSTATE #
###############

dictionary = hf.produce_groundstate(model; force=true);

@testset "Groundstate" begin
    ψ₀ = dictionary["groundstate"];
    H = dictionary["ham"];

    E_norm = -1.01631556

    Ne = hf.density_state(ψ₀);
    E0 = expectation_value(ψ₀, H) + μ.*Ne;
    E = sum(real(E0))/length(H)
    @test E≈E_norm atol=tol
end


###############
# EXCITATIONS #
###############

@testset "Excitations" begin
    resolution = 5;
    momenta = range(0, π, resolution);
    nums = 1;

    exc = hf.produce_excitations(model, momenta, nums; force=true);
    Es = exc["Es"];
    @test imag(Es)≈zeros(size(Es)) atol=1e-8
end


#########
# Tools #
#########

@testset "Tools" begin
    D = hf.dim_state(dictionary["groundstate"])
    @test typeof(D) == Vector{Int64}
    @test D > zeros(size(D))
end