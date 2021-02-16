### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 646d9580-6e3f-11eb-314e-ab4dd2a04b39
begin
	using Pkg
	Pkg.add("ISAData")
	
	using ISAData
end

# ╔═╡ b15553a2-6e3b-11eb-2462-5bed61b635d0
md"# Exercícios de Propulsão - U5"

# ╔═╡ 91250d2c-6e3c-11eb-2366-a356194cd2d3
md"## Análise de Ciclo Ideal - SAM SA-6 Gainful"

# ╔═╡ 631c5886-6e3f-11eb-04d3-850801ca6b42
ρ0, P0, T0, μ0 = ISAdata(0)

# ╔═╡ a55ba372-6e40-11eb-0d36-0f6d70fec899
sqrt(μ0/ρ0)

# ╔═╡ b9f92eb8-6e3c-11eb-1b04-bdc11a79e46d
function get_ideal_ramjet(M0, H0, Air, JetA, Engine)
	#  Cálculo de Desempenho de um motor Estatojato
	#   Método de análise de ciclo ideal
   
	h0 = H0
	ρ0, P0, T0, μ0 = ISAData(h0)

	Taur = 1 + (Air.gamma-1)/2*M0^2;
	Pir = Taur^(Air.gamma/(Air.gamma-1));

	Pid = 1;
	Taud = 1;

	Taub = Engine.Tt4/(T0*Taur*Taud);
	Pib = 1;
	Taulambda = Engine.Tt4/T0;
	f =  (Taulambda-Taur*Taud)...
		/(JetA.hpr/(Air.cp*T0)-Taulambda+Taur*Taud); 

	Taun = 1;
	Pin = 1;
	Pt9_P9 = Engine.P0_P9*Pir*Pid*Pib*Pin;
	M9 = sqrt(2/(Air.gamma-1)*...
			(Pt9_P9^((Air.gamma-1)/Air.gamma)-1));
	T9_Tt9 = 1/(1+(Air.gamma-1)/2*M9*M9);      
	T9_T0 = Taur*Taud*Taub*Taun*T9_Tt9;
	a9 = sqrt(Air.gamma*Air.R*T9_T0*T0);

	Performance.F_mdot0 = a0*((1+f)*M9*sqrt(T9_T0)-M0);

	Performance.FAratio = f; 

	Performance.SFC = Performance.FAratio/Performance.F_mdot0;  

	Performance.etat = 0.5*(a0^2*((1+f)*M9*M9*T9_T0-M0^2))/(f*JetA.hpr);      
	Performance.etap = 2*Performance.F_mdot0*M0...
									  /(a0*((1+f)*M9*M9*T9_T0-M0^2));  
	Performance.eta0 = Performance.etap*Performance.etat;                     
end

# ╔═╡ Cell order:
# ╟─b15553a2-6e3b-11eb-2462-5bed61b635d0
# ╠═646d9580-6e3f-11eb-314e-ab4dd2a04b39
# ╠═91250d2c-6e3c-11eb-2366-a356194cd2d3
# ╠═631c5886-6e3f-11eb-04d3-850801ca6b42
# ╠═a55ba372-6e40-11eb-0d36-0f6d70fec899
# ╠═b9f92eb8-6e3c-11eb-1b04-bdc11a79e46d
