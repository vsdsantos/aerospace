### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ dda05584-67fd-11eb-106b-eb97aea7bd8d
using PlutoUI, Plots; pyplot()

# ╔═╡ 230dd496-6954-11eb-1785-d1b0dc627c05
using Roots

# ╔═╡ d2b59398-67ee-11eb-306e-e9cc35e0f00c
md"# Exercícios de Propulsão - U4"

# ╔═╡ 41b808ca-67f2-11eb-0cc9-a1a709fb0f3e
md"""
## 1. Potência e Consumo
### Propriedades

Motor Lycoming IO-540-K
- 6 cilindros, 4 tempos
- Cilindrada 340 in³ (8849 cm³)
- Razão de compressão 8.7:1
- Potência Máxima Contínua (PCM)
  - AVGAS 300 hp (223.7 kW) @ 289.5 g/kWh, 2700 rpm
  - Etanol 320 hp (238.6 kW) @ 433.9 g/kWh, 2700 rpm
- Peso 466 lb (211.3 Kg)
"""

# ╔═╡ a2bea856-6881-11eb-1b54-a5dc504c988b
md"#### Atmosfera Padrão"

# ╔═╡ 2a035f98-67ef-11eb-120e-a196303a630c
T0, P0 = 273.15 + 30, 101325 # [K]

# ╔═╡ bfa96f00-6881-11eb-0050-d9b3b78418c2
md"#### Constanstes dos Gases"

# ╔═╡ b32d3ef0-6881-11eb-2bef-61522cddf836
R_universal = 8314.34 # [J/kgmol/K]

# ╔═╡ 747b3a90-6890-11eb-03be-f9d07b793e48
struct Gas
	R
	PM
	γ
	cv
	Gas(R, γ) = new(R, R_universal/R, γ, R/(γ-1))
end

# ╔═╡ c7ec737e-6881-11eb-27d7-333d80803de1
air = Gas(287.04, 1.4) #J/kg/K

# ╔═╡ cb2e4d8c-6890-11eb-2d74-6d57fd523a4a
air_comb = Gas(289.0, 1.35)

# ╔═╡ ef82dd38-6881-11eb-1394-a9e348c5cd7e
md"#### Volume e Razão de Compressão"

# ╔═╡ 2b5708a2-6882-11eb-24c4-afab48aa45b9
VolDTotal = 8849e-6 # m3 vol total (cilindradas)

# ╔═╡ 2db572f0-6882-11eb-3fd6-8b91446e0c0c
Ncil = 6 # N cilindros

# ╔═╡ 308e88e8-6882-11eb-0f1d-e5c415eda648
VolD = VolDTotal/Ncil # volume de cada cilindro

# ╔═╡ 34295a8c-6882-11eb-3fc5-d3a4e3ae6b04
rc = 8.7 # razão de compressão

# ╔═╡ 3f4b0d3e-6882-11eb-246c-095139aec7bc
md"#### Rotação do Motor"

# ╔═╡ 45d5d318-6882-11eb-18d7-0f761c251701
ω_rpm = 1000:100:3000

# ╔═╡ 646eb718-6882-11eb-0646-05f8873b5fca
md"#### Combustível"

# ╔═╡ 24c67708-68bf-11eb-2ad2-ff24267c734d
md"Manete de Mistura: λ_mistura"

# ╔═╡ 334468a8-68bf-11eb-2368-57668bacfbb4
@bind λ_mistura Slider(0.5:0.02:1.5,show_value=true, default=0.9)

# ╔═╡ 7462b62e-688a-11eb-1e2f-1d28177a7cb9
struct Fuel
	PCI::Real # J / kg
	AF_esteq::Real # kg air / kg fuel
	λ::Real
	AF::Real # kg air/ kg fuel
	f::Real # kg fuel / kg
	f_esteq::Real
	Fuel(PCI, AF_esteq, λ) = new(PCI, AF_esteq, λ, AF_esteq*λ, 1/(AF_esteq*λ+1), 1/(AF_esteq+1))
end

# ╔═╡ 08c0fb00-67f0-11eb-32f1-2739dadefa91
E94 = Fuel(32e6, 9, λ_mistura)

# ╔═╡ 155afa3c-67f0-11eb-06ba-6bdbfcd22b4e
AVGAS = Fuel(42e6, 14, λ_mistura)

# ╔═╡ f4e3db6a-6949-11eb-252a-69bb1cc866fb
md"### Avaliação da potência e consumo pela rotação"

# ╔═╡ bae39990-6896-11eb-34f0-7916d7aeaeab
md"### Processos"

# ╔═╡ 758def7a-68b0-11eb-2881-4978c344509d
function não_ideal(T, P, τ, π)
	return τ.*T, π.*P, τ, π
end

# ╔═╡ a584de80-68a8-11eb-3bf7-936d8b9a39d4
function processo_isobárico_não_ideal(T, P, η)
	
	τ = 1
	π = η

	não_ideal(T, P, τ, π)
end

# ╔═╡ c997cfec-6896-11eb-1586-cbaa51d685d1
function compressão_isentrópica_não_ideal(T, P, γ, rc, η)
	τ = rc.^(γ.-1)
	π = τ.^(γ.*η./(γ.-1))
	
	não_ideal(T, P, τ, π)
end

# ╔═╡ 34d07f32-6803-11eb-31b8-e1b8d3223bec
function combustão_não_ideal(T, P, η, fuel::Fuel, air::Gas, air_pos::Gas)
		
	if fuel.f <= fuel.f_esteq
		f = fuel.f
	else
		f = fuel.f_esteq
	end
	PCI = fuel.PCI
	c_v = air.cv
	
	τ_b = 1 .+ η.*f.*PCI./(c_v.*T)
	π_b = τ_b.*air.PM./air_pos.PM

	não_ideal(T, P, τ_b, π_b)
end

# ╔═╡ eeee9572-68b0-11eb-1d39-19ea5ae1876e
function expansão_isentrópica_não_ideal(T, P, γ, rc, η)
	τ = 1 ./rc.^(γ.-1)
	π = τ.^(γ./η.*(γ.-1))
	
	não_ideal(T, P, τ, π)
end

# ╔═╡ fec79dce-6884-11eb-166b-3d2b7adfbcc9
function blow_out(T, P, π_b, π_e, π_c, ξ, η)
	π_bo = 1 ./(ξ.*π_e.*π_b.*π_c)
	τ_bo = π_bo./η
	
	não_ideal(T, P, τ_bo, π_bo)
end

# ╔═╡ b0133f62-6949-11eb-107f-657b61fa4565
function ciclo_otto(fuel, η_vol, ω_rpm, T0, P0)
	η_c, η_b, η_e, η_bo, ξ_bo, ξ_ex = 0.96, 0.7, 0.4, 0.3, 0.4, 0.95
	T1, P1, τ_ad, π_ad = processo_isobárico_não_ideal(T0, P0, η_vol)
	T2, P2, τ_c, π_c = compressão_isentrópica_não_ideal(T1, P1, air.γ, rc, η_c)
	T3, P3, τ_b, π_b = combustão_não_ideal(T2, P2, η_b, fuel, air, air_comb)
	T4, P4, τ_e, π_e = expansão_isentrópica_não_ideal(T3, P3, air.γ, rc, η_e)
	T5, P5, τ_bo, π_bo = blow_out(T4, P4, π_b, π_e, π_c, ξ_bo, η_bo)
	T6, P6, τ_ex, π_ex = processo_isobárico_não_ideal(T5, P5, ξ_ex)
	efm = 0.98
	WM = efm.*(air.cv.*τ_c.*τ_ad.*T0.*(τ_b .- 1)
				.- air_comb.cv.*τ_ad.*T0.*(τ_e.*τ_b.*τ_c .- 1)
				.-(π_ex.*π_bo.*π_e.*π_b.*π_c.*π_ad .- 1).*air.R.*T0)
	M = VolD.*π_ad.*P0./(air.R.*τ_ad.*T0)
	N = ω_rpm./60 #rps
	ω = 2 .*pi.*N # rad/s
	Torque = M.*WM.*Ncil./(4*pi)
	Pot = Torque.*ω
	mdot = 2 .* M .* N
	Cf = fuel.f.*mdot
	Pot.*1e-3, Cf*3600, mdot
end

# ╔═╡ 9f390b22-6949-11eb-0076-4daa0731af9c
begin
	plot(color_palette=palette(:tab10, 4))
	for carga in [1 .75 .65 .5]
		plot!(ω_rpm, ciclo_otto(E94, carga, ω_rpm, T0, P0)[1],
			label=string("E94 - Carga ",Int64(carga*100), "%"))
	end
	for carga in [1 .75 .65 .5]
		plot!(ω_rpm, ciclo_otto(AVGAS, carga, ω_rpm, T0, P0)[1],
			line=:dash,
			label=string("AVGAS - Carga ",Int64(carga*100), "%"))
	end

	plot!(xlabel="ω [rpm]", ylabel="Pot [kW]")
end

# ╔═╡ c7ba0b00-6949-11eb-3530-dd80b8647640
begin
	plot(color_palette=palette(:tab10, 4))
	for carga in [1 .75 .65 .5]
		plot!(ω_rpm, ciclo_otto(E94, carga, ω_rpm, T0, P0)[2],
			label=string("E94 - Carga ",Int64(carga*100), "%"))
	end
	for carga in [1 .75 .65 .5]
		plot!(ω_rpm, ciclo_otto(AVGAS, carga, ω_rpm, T0, P0)[2],
			line=:dash,
			label=string("AVGAS - Carga ",Int64(carga*100), "%"))
	end

	plot!(xlabel="ω [rpm]", ylabel="Consumo [kg/h]")
end

# ╔═╡ b705caf0-694a-11eb-2910-d1d9d5c3c8c9
md"## Teto de Voo"

# ╔═╡ 6a43be32-694c-11eb-3ced-bda867d953f9
md"O teto de voo é definido como quando a potência disponível se iguala à potência requerida. Como a potência requerida a nível do mar é 50% da PCM podemos estimar o teto da aeronave."

# ╔═╡ f63634e2-694c-11eb-120c-479c60bcbefa
p_req_e94 = 0.5*ciclo_otto(E94, 1, 2700, T0, P0)[1]

# ╔═╡ a38a5ccc-694d-11eb-18b7-979d25cf471a
p_req_avgas = 0.5*ciclo_otto(AVGAS, 1, 2700, T0, P0)[1]

# ╔═╡ 30eba6d2-694e-11eb-361b-138d0c30591e
md"Utilizaremos a maior potência como potência requerida por ser mais conservativo."

# ╔═╡ 4a69d306-694e-11eb-372e-8b03770d11d5
p_req = max(p_req_e94, p_req_avgas)

# ╔═╡ 2a4aea56-694b-11eb-1a7c-d3602e60160b
function std_atm(h, T_ref, P_ref)
	T = T_ref .- 0.00649*h
	P = P_ref*(T./T_ref).^5.256
	ρ = 1 ./ (air.R.*T./P)
	T, P, ρ
end

# ╔═╡ cdd6d406-694d-11eb-04be-85c0002924b2
begin
	plot()
	
	hs = 0:100:8000
	
	T, P, ρ = std_atm(hs, T0, P0)
	
	e94 = ciclo_otto(E94, 1, 2700, T, P)[1]
	avgas = ciclo_otto(AVGAS, 1, 2700, T, P)[1]
	
	i_e94 = findmin(abs.(e94.-p_req))[2]
	i_avgas = findmin(abs.(avgas.-p_req))[2]
		
	plot!(hs, e94, label="E94")
	plot!(hs, avgas, label="AVGAS")
	
	plot!([0; 8000], p_req.*[1; 1],
		label=string(round(p_req)," kW"), c=:black, l=:dash)
	
	plot!(hs[i_e94].*[1;1], e94[i_e94].*[0;1],
		l=:dash, label=string(round(hs[i_e94])," m"))
	plot!(hs[i_avgas].*[1;1], avgas[i_avgas].*[0;1],
		l=:dash, label=string(round(hs[i_avgas])," m"))
	
	plot!(xlabel="Altitude [m]", ylabel="Pot [kW]", ylim=(50,300), xlim=(0,8000))
end

# ╔═╡ 8ed3be24-694b-11eb-0bd5-4d64ac056a05
md"## Regulagem da manete de potência"

# ╔═╡ c4f7a4a0-6952-11eb-00f3-5961b9eaf450
md"Diâmetro da válvula borboleta: 50 mm"

# ╔═╡ 449bbc74-695c-11eb-04a9-4b7d063fcd92
D_p = 0.05

# ╔═╡ fb6a9b00-6952-11eb-313c-516e751da209
A_p(ψ) = π*D_p*(1-cos(ψ))/4

# ╔═╡ 4fec261c-6953-11eb-3035-0b69c21440fc
c_d(ψ) = 0.0128*exp(2.75ψ)

# ╔═╡ 8ab77f5a-695d-11eb-2ad8-1d83eda7712f
L(ψ, m_dot, P0, ρ) = 1/(1+ m_dot^2/(2ρ*P0*(c_d(ψ)*A_p(ψ))^2))

# ╔═╡ 27348f7a-695d-11eb-3031-0dbeb5add17a
let
	plot()
	cargas = 0.5:.099:.999999
	altitudes = 0:4000:12000
	for alt in altitudes
		T, P, ρ = std_atm(alt, T0, P0)
		ψs_e94 = []
		for carga in cargas
			m_dot = ciclo_otto(E94, carga, 2700, T, P)[3]
			push!(ψs_e94, find_zero((x)-> L(x, m_dot, P, ρ)-carga, π/6)*180/pi)
		end
		plot!(ψs_e94, cargas.*100,
			marker=true, label=string(alt, " m"))
	end
	plot!(xlabel="Abertura da Válvula [°]", ylabel="Carga [%]")
end

# ╔═╡ 232bb8a6-6960-11eb-31a4-37f2f34f7545
md"""
Verifica-se que a mudança na altitude de voo modifica linearmente a abertura da válvula para uma determinada carga e dentro do envelope de voo. Então é possível que o piloto corrija a abertura seguindo uma regra simples, proporcional à carga desejada, altitude e abertura no nível do mar.

Uma Solução possível seria dois gráficos, um mostrando o comportamento a nível do mar, e outro indicando o adicional de abertura da válvula para cada condição de carga e altitude.
"""

# ╔═╡ 1d1c50b6-6969-11eb-1798-3743e38c5bdf
let
	plot()
	cargas = 0.5:.099/8:.999999
	T, P, ρ = std_atm(0, T0, P0)
	ψs_e94 = []
	for carga in cargas
		m_dot = ciclo_otto(E94, carga, 2700, T, P)[3]
		push!(ψs_e94, find_zero((x)-> L(x, m_dot, P, ρ)-carga, π/6)*180/pi)
	end
	plot!(ψs_e94, cargas.*100,
		marker=true, label=string("nível do mar"))
	plot!(xlabel="Abertura da Válvula [°]", ylabel="Carga [%]")
end

# ╔═╡ cd0ad198-696a-11eb-17ba-53f979f07f3c
let
	plot()
	cargas = 0.5:.099/8:.99999
	altitudes = 0:100:12000
	ψ_alt = []
	for alt in altitudes
		T, P, ρ = std_atm(alt, T0, P0)
		ψs_e94 = []
		for carga in cargas
			m_dot = ciclo_otto(E94, carga, 2700, T, P)[3]
			push!(ψs_e94, find_zero((x)-> L(x, m_dot, P, ρ)-carga, π/6)*180/pi)
		end
		push!(ψ_alt, ψs_e94)
	end
	ψ = hcat(ψ_alt...)
	contour!(altitudes./1000, cargas.*100, ψ.-ψ[:,1], fill=true)
	# heatmap!(altitudes./1000, cargas.*100, ψ.-ψ[:,1])
	plot!(xlabel="Altitude [km]", ylabel="Carga [%]", title="Variação do ângulo de Abertura da Válvula Δψ [°]")
	# ψ
end

# ╔═╡ a70a078c-695f-11eb-29f0-c577c378f43c
md"## Motores Diesel"

# ╔═╡ b0df59e2-695f-11eb-0124-3717f5ac4aaa
md"""
### 1.
Dado o falor λ=1.6 e AF estequiométrico de 14:1 a razão ar combustível real será de:
"""

# ╔═╡ cfb01676-6974-11eb-2169-7b86d40f66f7
AF = let
	λ = 1.6
	AF_esteq = 14
	λ*AF_esteq
end

# ╔═╡ f190f33c-6974-11eb-1ac3-470ab0834104
md"""### 2.
A massa total de combustível por cilindro será a razão da massa total pelo AF real:
"""

# ╔═╡ 20ec0c70-6975-11eb-309b-155f5c56ece6
m_fuel = let
	m_total = 2725
	m_total/AF
end

# ╔═╡ 44e84e5e-6975-11eb-2e50-5f46f426d972
md"""### 3.
A razão volumétrica ou razão de compressão/expansão será dada por:
"""

# ╔═╡ 52e05b8c-6975-11eb-2e9c-5baa13c5878b
rv = let
	v4 = 1.31e-3
	v3 = 1.12e-4
	v4/v3
end

# ╔═╡ 77b6b438-6975-11eb-32ff-8760fab04a37
md"""### 4.
A eficiência térmica será dada por:
"""

# ╔═╡ ba914354-6975-11eb-3f7e-676e6b55dfc7
η_t = let
	W_util = 146
	M_f = 0.0092
	PCI = 4.3e4
	W_util/M_f/PCI
end

# ╔═╡ 490ce852-6976-11eb-1191-918b0a5df9b0
md"""
## Estudo de Caso
"""

# ╔═╡ 69579ab4-6976-11eb-07ce-f39008a1d1f6
md"""
Os textos apresentados indicam uma vantagem e grande tendência à utilização dos motores a Diesel em relação ao uso de gasolina de aviação. Em ambos os estudos, dentro das realidades da aviação geral brasileira e americana, existem vantagens econômicas na utilização do Diesel. No caso brasileiro, o alto custo e baixa disponibilidade da gasolina de aviação favorece o uso do Diesel, que é consideravelmente mais barato e mais abundante no mercado. No caso americano não há tanta diferênça de custo, mas o ganho em vida útil do motor é significativo em operações de alta altitude.

Fica entendido que nos próximos anos haverá uma grande tendência dos motores Diesel na aviação geral.
"""

# ╔═╡ Cell order:
# ╟─d2b59398-67ee-11eb-306e-e9cc35e0f00c
# ╠═dda05584-67fd-11eb-106b-eb97aea7bd8d
# ╟─41b808ca-67f2-11eb-0cc9-a1a709fb0f3e
# ╟─a2bea856-6881-11eb-1b54-a5dc504c988b
# ╠═2a035f98-67ef-11eb-120e-a196303a630c
# ╟─bfa96f00-6881-11eb-0050-d9b3b78418c2
# ╟─b32d3ef0-6881-11eb-2bef-61522cddf836
# ╟─c7ec737e-6881-11eb-27d7-333d80803de1
# ╟─cb2e4d8c-6890-11eb-2d74-6d57fd523a4a
# ╠═747b3a90-6890-11eb-03be-f9d07b793e48
# ╟─ef82dd38-6881-11eb-1394-a9e348c5cd7e
# ╟─2b5708a2-6882-11eb-24c4-afab48aa45b9
# ╟─2db572f0-6882-11eb-3fd6-8b91446e0c0c
# ╟─308e88e8-6882-11eb-0f1d-e5c415eda648
# ╟─34295a8c-6882-11eb-3fc5-d3a4e3ae6b04
# ╟─3f4b0d3e-6882-11eb-246c-095139aec7bc
# ╟─45d5d318-6882-11eb-18d7-0f761c251701
# ╟─646eb718-6882-11eb-0646-05f8873b5fca
# ╟─24c67708-68bf-11eb-2ad2-ff24267c734d
# ╟─334468a8-68bf-11eb-2368-57668bacfbb4
# ╟─08c0fb00-67f0-11eb-32f1-2739dadefa91
# ╟─155afa3c-67f0-11eb-06ba-6bdbfcd22b4e
# ╠═7462b62e-688a-11eb-1e2f-1d28177a7cb9
# ╟─f4e3db6a-6949-11eb-252a-69bb1cc866fb
# ╠═9f390b22-6949-11eb-0076-4daa0731af9c
# ╠═c7ba0b00-6949-11eb-3530-dd80b8647640
# ╟─bae39990-6896-11eb-34f0-7916d7aeaeab
# ╠═b0133f62-6949-11eb-107f-657b61fa4565
# ╠═758def7a-68b0-11eb-2881-4978c344509d
# ╠═a584de80-68a8-11eb-3bf7-936d8b9a39d4
# ╠═c997cfec-6896-11eb-1586-cbaa51d685d1
# ╠═34d07f32-6803-11eb-31b8-e1b8d3223bec
# ╠═eeee9572-68b0-11eb-1d39-19ea5ae1876e
# ╠═fec79dce-6884-11eb-166b-3d2b7adfbcc9
# ╟─b705caf0-694a-11eb-2910-d1d9d5c3c8c9
# ╟─6a43be32-694c-11eb-3ced-bda867d953f9
# ╠═f63634e2-694c-11eb-120c-479c60bcbefa
# ╠═a38a5ccc-694d-11eb-18b7-979d25cf471a
# ╟─30eba6d2-694e-11eb-361b-138d0c30591e
# ╠═4a69d306-694e-11eb-372e-8b03770d11d5
# ╠═cdd6d406-694d-11eb-04be-85c0002924b2
# ╠═2a4aea56-694b-11eb-1a7c-d3602e60160b
# ╟─8ed3be24-694b-11eb-0bd5-4d64ac056a05
# ╟─c4f7a4a0-6952-11eb-00f3-5961b9eaf450
# ╠═449bbc74-695c-11eb-04a9-4b7d063fcd92
# ╠═fb6a9b00-6952-11eb-313c-516e751da209
# ╠═4fec261c-6953-11eb-3035-0b69c21440fc
# ╠═8ab77f5a-695d-11eb-2ad8-1d83eda7712f
# ╟─230dd496-6954-11eb-1785-d1b0dc627c05
# ╠═27348f7a-695d-11eb-3031-0dbeb5add17a
# ╟─232bb8a6-6960-11eb-31a4-37f2f34f7545
# ╠═1d1c50b6-6969-11eb-1798-3743e38c5bdf
# ╠═cd0ad198-696a-11eb-17ba-53f979f07f3c
# ╟─a70a078c-695f-11eb-29f0-c577c378f43c
# ╟─b0df59e2-695f-11eb-0124-3717f5ac4aaa
# ╠═cfb01676-6974-11eb-2169-7b86d40f66f7
# ╟─f190f33c-6974-11eb-1ac3-470ab0834104
# ╠═20ec0c70-6975-11eb-309b-155f5c56ece6
# ╟─44e84e5e-6975-11eb-2e50-5f46f426d972
# ╠═52e05b8c-6975-11eb-2e9c-5baa13c5878b
# ╟─77b6b438-6975-11eb-32ff-8760fab04a37
# ╠═ba914354-6975-11eb-3f7e-676e6b55dfc7
# ╟─490ce852-6976-11eb-1191-918b0a5df9b0
# ╟─69579ab4-6976-11eb-07ce-f39008a1d1f6
