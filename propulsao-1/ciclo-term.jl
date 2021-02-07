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
using PlutoUI, Plots; gr()

# ╔═╡ d2b59398-67ee-11eb-306e-e9cc35e0f00c
md"# Potência e Consumo IO-540-K"

# ╔═╡ 41b808ca-67f2-11eb-0cc9-a1a709fb0f3e
md""" ## Propriedades

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
md"### Propriedades de Referência (Atmosfera Padrão)"

# ╔═╡ 2a035f98-67ef-11eb-120e-a196303a630c
T0 = 273.15 + 15 # [K]

# ╔═╡ ad660e52-6881-11eb-1f35-f3aea8caae22
P0 = 101325 # [Pa] Controlado pela altitude

# ╔═╡ b32d3ef0-6881-11eb-2bef-61522cddf836
R_universal = 8314.34 # [J/kgmol/K]

# ╔═╡ bfa96f00-6881-11eb-0050-d9b3b78418c2
md"### Constanstes dos Gases"

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
md"### Volume e Razão de Compressão"

# ╔═╡ 2b5708a2-6882-11eb-24c4-afab48aa45b9
VolDTotal = 8849e-6 # m3 vol total (cilindradas)

# ╔═╡ 2db572f0-6882-11eb-3fd6-8b91446e0c0c
Ncil = 6 # N cilindros

# ╔═╡ 308e88e8-6882-11eb-0f1d-e5c415eda648
VolD = VolDTotal/Ncil # volume de cada cilindro

# ╔═╡ 34295a8c-6882-11eb-3fc5-d3a4e3ae6b04
rc = 8.7 # razão de compressão

# ╔═╡ 3f4b0d3e-6882-11eb-246c-095139aec7bc
md"### Rotação do Motor"

# ╔═╡ 45d5d318-6882-11eb-18d7-0f761c251701
ω_rpm = 1000:100:3000

# ╔═╡ 46c50832-6882-11eb-14fb-7d41ca290646
N = ω_rpm./60 #rps

# ╔═╡ 4898beb0-6882-11eb-1775-c39565dd1bf6
ω = 2 .*pi.*N # rad/s

# ╔═╡ 646eb718-6882-11eb-0646-05f8873b5fca
md"### Combustível"

# ╔═╡ 24c67708-68bf-11eb-2ad2-ff24267c734d
md"Manete de Mistura: λ"

# ╔═╡ 334468a8-68bf-11eb-2368-57668bacfbb4
@bind λ_mistura Slider(0.5:0.02:1.5,show_value=true, default=0.9)

# ╔═╡ c958150c-67fe-11eb-2554-d5d6fb2c6b6d
md"#### Escolha do combustível:"

# ╔═╡ 2c36d02e-67fe-11eb-0a52-5bce5abfd563
@bind fuel_name Radio(["E94"=>"Etanol E94","AVGAS"=>"AVGAS"], default="E94") 

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

# ╔═╡ 2867b0de-67f0-11eb-2823-d59e0edd0af8
begin
	if fuel_name == "E94"
		fuel = E94
	elseif fuel_name == "AVGAS"
		fuel = AVGAS
	end
	md""
end

# ╔═╡ a519715c-6800-11eb-3443-15540f064b2a
md"## Ciclo Termodinâmico"

# ╔═╡ 731f0926-687a-11eb-0a73-3f61c20d3c4e
md"""
### Processos
- Isentrópico -> n = γ
- Isotérmico -> n = 1
- Isobárico -> n = 0
- Isocórico -> n = -∞
- Politrópico
"""

# ╔═╡ 5850e282-6897-11eb-0835-dd3a70391da9
md"""
### Ciclo Otto
- 0-1 Admissão Isobárica
- 1-2 Compressão Isentrópica
- 2-3 Queima Isocórica
- 3-4 Expansão Isentrópica
- 4-5 Expansão Isocórica
- 5-6 Exaustão Isobárica
"""

# ╔═╡ 276dd8a2-6881-11eb-3cb1-f7620c7f3bc1
md"""
### Nomenclaturas
- π -> Razão de Pressões
- τ -> Razão de Temperaturas
- η, ξ -> Eficiência
"""

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
	
	τ_b = 1 + η.*f.*PCI./(c_v.*T)
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

# ╔═╡ 3f8ed28a-6802-11eb-1f77-c550910508c8
md"### 0-1 Admissão"

# ╔═╡ 6d6a6838-68aa-11eb-2c3b-af1551174172
md"Eficiência Volumétrica: η_vol"

# ╔═╡ 79c2d912-68aa-11eb-39b3-5d2db87c2017
@bind η_vol Slider(0:0.01:1, default=0.9, show_value=true)

# ╔═╡ ba9f928a-6801-11eb-0de2-677e957305b7
begin
	acel = 0.75
	# η_vol = 0.90 # controle de manete de potência
	T1, P1, τ_ad, π_ad = processo_isobárico_não_ideal(T0, P0, η_vol)
	T1-273.15, P1*1e-5
end

# ╔═╡ 4991b82e-6802-11eb-3bd7-3db39fb7576a
md"### 1-2 Compressão"

# ╔═╡ 5037c5c6-68aa-11eb-009e-9b411cf27ed6
md"Eficiência de Compressão: η_c"

# ╔═╡ 583ca296-68aa-11eb-089f-b929955ebb42
@bind η_c Slider(0:0.01:1, default=0.96, show_value=true)

# ╔═╡ 4375f912-67f0-11eb-1ff7-ff530b8a8104
begin
	# η_c = 0.94
	T2, P2, τ_c, π_c = compressão_isentrópica_não_ideal(T1, P1, air.γ, rc, η_c)
	T2-273.15, P2*1e-5
end

# ╔═╡ 2f10ea14-6803-11eb-39d0-d32366af4a94
md"### 2-3 Combustão"

# ╔═╡ fad8f228-68a7-11eb-23cf-cd8004261dd3
md"Eficiência de Combustão: η_b"

# ╔═╡ 8e0678b4-68a7-11eb-2671-f17cd1923fdd
@bind η_b Slider(0:0.01:1, default=0.66, show_value=true)

# ╔═╡ 4bf921d6-67f0-11eb-26bf-d93603dd6870
begin
	# η_b = 0.81   # controla a potencia do motor
	T3, P3, τ_b, π_b = combustão_não_ideal(T2, P2, η_b, fuel, air, air_comb)
	T3-273.15, P3*1e-5
end

# ╔═╡ 42fcd002-687a-11eb-1b36-c1da5dad7aba
md"### 3-4 Expansão"

# ╔═╡ 1a9130d0-68a8-11eb-1f0b-6dd2006df668
md"Eficiência de Expansão: η_e"

# ╔═╡ 282e9c1e-68a8-11eb-21d1-e31ae0e7a7b9
@bind η_e Slider(0:0.01:1, default=0.31, show_value=true)

# ╔═╡ 5e072fd0-67f0-11eb-003f-43d3c0258fc7
begin
	# Expansao Isentrópica não ideal
	# η_e = 0.94
	T4, P4, τ_e, π_e = expansão_isentrópica_não_ideal(T3, P3, air.γ, rc, η_e)
	T4-273.15, P4*1e-5
end

# ╔═╡ 9bf15316-6884-11eb-1f74-a3e705284839
md"### Blow-out"

# ╔═╡ 47705f06-68a8-11eb-37f2-c35ef506f361
md"Eficiência Térmica de Blow-out: η_bo"

# ╔═╡ 56dae414-68a8-11eb-1d82-9ba7b1301316
@bind η_bo Slider(0:0.01:1, default=0.28, show_value=true)

# ╔═╡ 7bcd6cec-68a8-11eb-0fe7-75058595185a
md"Eficiência de Pressão de Blow-out: ξ_bo"

# ╔═╡ 88339ed4-68a8-11eb-025b-bda4f8caf107
@bind ξ_bo Slider(0:0.01:1, default=0.4, show_value=true)

# ╔═╡ 6575ce98-67f0-11eb-32d3-0bef0d249dd3
begin
	# Blow-out
	# ξ_bo = 0.40
	# η_bo = 0.88
	T5, P5, τ_bo, π_bo = blow_out(T4, P4, π_b, π_e, π_c, ξ_bo, η_bo)
	T5-273.15, P5*1e-5	
end

# ╔═╡ f0268b78-6885-11eb-1ef6-439c25c3f010
md"### Exaustão"

# ╔═╡ 9a2b3718-68a9-11eb-0057-2dc8464b0dd4
md"Eficiência de Exaustão: ξ_ex"

# ╔═╡ a4f73b92-68a9-11eb-228f-afbffd7bd49a
@bind ξ_ex Slider(0:0.01:1, default=0.95, show_value=true)

# ╔═╡ 867d27ee-67f0-11eb-0936-f316ccf824b6
begin
	# Exaustao
	# η_ex = 0.95
	T6, P6, τ_ex, π_ex = processo_isobárico_não_ideal(T5, P5, ξ_ex)
	T6-273.15, P6*1e-5
end

# ╔═╡ dc188ada-6800-11eb-3b5a-4907bc4bbffa
md"## Desempenho"

# ╔═╡ 50f269ae-6886-11eb-0975-47c5feb2bf43
efm = 0.98

# ╔═╡ 55351e56-6886-11eb-1c91-f9ea3d4e9b12
WM = efm.*(air.cv.*τ_c.*τ_ad.*T0.*(τ_b.-1).-air_comb.cv.*τ_ad.*T0.*(τ_e.*τ_b.*τ_c-1)
			  .-(π_ex.*π_bo.*π_e.*π_b.*π_c.*π_ad.-1).*air.R.*T0)


# ╔═╡ 8b62e64c-6886-11eb-0c13-79cafb18c87d
M = VolD*π_ad*P0/(air.R*τ_ad*T0)

# ╔═╡ 95a073ac-6886-11eb-238d-3538f0899275
ef_t = WM/fuel.f/fuel.PCI

# ╔═╡ 9831175c-6886-11eb-2472-41d50880c5c0
mdot = M*2*N

# ╔═╡ 9ad11ef0-6886-11eb-37b3-8d36401d848e
Cf = fuel.f*mdot

# ╔═╡ 9fdb4e26-6886-11eb-141c-7d21e30c9e21
Torque = M.*WM.*Ncil./(4*pi)

# ╔═╡ a248a1ba-6886-11eb-2f81-6996389264b7
Pot = Torque.*ω

# ╔═╡ a443c76a-6886-11eb-0160-7397360b3077
SFC = Cf./Pot

# ╔═╡ a74e135c-6886-11eb-082d-2d8f9d8d2d6e
PME = M.*WM.*Ncil./VolD

# ╔═╡ da8824e4-688e-11eb-1418-75a5b015fb9f
Ps = [P0 P1 P2 P3 P4 P5 P6]'

# ╔═╡ 2878a90c-6895-11eb-3849-93faad3f4f7d
Ts = [T0 T1 T2 T3 T4 T5 T6]'

# ╔═╡ 2b9792f6-6895-11eb-3305-7f493a44f99f
Vs = [VolD/rc
	  VolD
	  VolD/rc
	  VolD/rc
	  VolD
	  VolD
	  VolD/rc]

# ╔═╡ d1a03fb6-6886-11eb-3ae5-47203575b373
begin
	plot(Vs, Ps.*1e-5,
		marker=true,
		mz=Ts.-273.15,
		markersize=(4*Ts./T3 .+ 2),
		alpha=0.8,
		series_annotations= text.(0:6, :top),
		label="Ciclo Otto não ideal")
	plot!(xlabel="V", ylabel="P [bar]", title="P vs V", scale=:log10)
end

# ╔═╡ 0502376e-68c1-11eb-374c-af049fcdb28d
md"#### Carga"

# ╔═╡ 093cde1a-68c1-11eb-0aff-cfceb9e7ffca
100*P1/P0

# ╔═╡ b8bb38a0-67f1-11eb-089c-5f598630c7e9
md"#### Potência [kW]"

# ╔═╡ c2e62ca2-67f1-11eb-3d4b-cb41a8cf5f12
Pot*1e-3

# ╔═╡ decaa3c8-68cb-11eb-3460-e133e9c154e4
begin
	plot(ω_rpm, Pot*1e-3, label="Carga 100%")
	plot!(xlabel="ω [rpm]", ylabel="Pot [kW]")
end

# ╔═╡ c901233a-67f1-11eb-1af2-f110d820a560
md"#### Consumo"

# ╔═╡ d03106c0-67f1-11eb-120b-1de57838ccc7
Cf*3600

# ╔═╡ d3d9d32e-67f1-11eb-0268-c7e98f09cad3
md"#### Torque"

# ╔═╡ da821ace-67f1-11eb-2c0b-63561ae3c7cc
Torque/9.81

# ╔═╡ df2b0cb6-67f1-11eb-1d1d-e71fe439882d
md"#### Consumo específico"

# ╔═╡ e718de30-67f1-11eb-0128-bb5a8b12028f
SFC*1e6*3600

# ╔═╡ eebc7f14-67f1-11eb-0035-ed3c54af7404
md"#### Eficiência térmica"

# ╔═╡ f4a1b55e-67f1-11eb-2c90-23285b067b53
ef_t*100

# ╔═╡ f949e7f2-67f1-11eb-0825-9db20a8475b8
md"#### PME"

# ╔═╡ 02716f58-67f2-11eb-10b7-5fb40a406c40
PME*1e-5

# ╔═╡ Cell order:
# ╟─d2b59398-67ee-11eb-306e-e9cc35e0f00c
# ╠═dda05584-67fd-11eb-106b-eb97aea7bd8d
# ╟─41b808ca-67f2-11eb-0cc9-a1a709fb0f3e
# ╟─a2bea856-6881-11eb-1b54-a5dc504c988b
# ╟─2a035f98-67ef-11eb-120e-a196303a630c
# ╟─ad660e52-6881-11eb-1f35-f3aea8caae22
# ╟─b32d3ef0-6881-11eb-2bef-61522cddf836
# ╟─bfa96f00-6881-11eb-0050-d9b3b78418c2
# ╟─c7ec737e-6881-11eb-27d7-333d80803de1
# ╟─cb2e4d8c-6890-11eb-2d74-6d57fd523a4a
# ╟─747b3a90-6890-11eb-03be-f9d07b793e48
# ╟─ef82dd38-6881-11eb-1394-a9e348c5cd7e
# ╟─2b5708a2-6882-11eb-24c4-afab48aa45b9
# ╟─2db572f0-6882-11eb-3fd6-8b91446e0c0c
# ╟─308e88e8-6882-11eb-0f1d-e5c415eda648
# ╟─34295a8c-6882-11eb-3fc5-d3a4e3ae6b04
# ╟─3f4b0d3e-6882-11eb-246c-095139aec7bc
# ╟─45d5d318-6882-11eb-18d7-0f761c251701
# ╟─46c50832-6882-11eb-14fb-7d41ca290646
# ╟─4898beb0-6882-11eb-1775-c39565dd1bf6
# ╟─646eb718-6882-11eb-0646-05f8873b5fca
# ╟─24c67708-68bf-11eb-2ad2-ff24267c734d
# ╟─334468a8-68bf-11eb-2368-57668bacfbb4
# ╟─08c0fb00-67f0-11eb-32f1-2739dadefa91
# ╟─155afa3c-67f0-11eb-06ba-6bdbfcd22b4e
# ╟─c958150c-67fe-11eb-2554-d5d6fb2c6b6d
# ╠═2c36d02e-67fe-11eb-0a52-5bce5abfd563
# ╟─2867b0de-67f0-11eb-2823-d59e0edd0af8
# ╟─7462b62e-688a-11eb-1e2f-1d28177a7cb9
# ╟─a519715c-6800-11eb-3443-15540f064b2a
# ╟─731f0926-687a-11eb-0a73-3f61c20d3c4e
# ╟─5850e282-6897-11eb-0835-dd3a70391da9
# ╟─276dd8a2-6881-11eb-3cb1-f7620c7f3bc1
# ╟─bae39990-6896-11eb-34f0-7916d7aeaeab
# ╟─758def7a-68b0-11eb-2881-4978c344509d
# ╟─a584de80-68a8-11eb-3bf7-936d8b9a39d4
# ╟─c997cfec-6896-11eb-1586-cbaa51d685d1
# ╟─34d07f32-6803-11eb-31b8-e1b8d3223bec
# ╟─eeee9572-68b0-11eb-1d39-19ea5ae1876e
# ╟─fec79dce-6884-11eb-166b-3d2b7adfbcc9
# ╟─3f8ed28a-6802-11eb-1f77-c550910508c8
# ╟─6d6a6838-68aa-11eb-2c3b-af1551174172
# ╟─79c2d912-68aa-11eb-39b3-5d2db87c2017
# ╟─ba9f928a-6801-11eb-0de2-677e957305b7
# ╟─4991b82e-6802-11eb-3bd7-3db39fb7576a
# ╟─5037c5c6-68aa-11eb-009e-9b411cf27ed6
# ╠═583ca296-68aa-11eb-089f-b929955ebb42
# ╟─4375f912-67f0-11eb-1ff7-ff530b8a8104
# ╟─2f10ea14-6803-11eb-39d0-d32366af4a94
# ╟─fad8f228-68a7-11eb-23cf-cd8004261dd3
# ╠═8e0678b4-68a7-11eb-2671-f17cd1923fdd
# ╟─4bf921d6-67f0-11eb-26bf-d93603dd6870
# ╟─42fcd002-687a-11eb-1b36-c1da5dad7aba
# ╟─1a9130d0-68a8-11eb-1f0b-6dd2006df668
# ╠═282e9c1e-68a8-11eb-21d1-e31ae0e7a7b9
# ╟─5e072fd0-67f0-11eb-003f-43d3c0258fc7
# ╟─9bf15316-6884-11eb-1f74-a3e705284839
# ╟─47705f06-68a8-11eb-37f2-c35ef506f361
# ╠═56dae414-68a8-11eb-1d82-9ba7b1301316
# ╟─7bcd6cec-68a8-11eb-0fe7-75058595185a
# ╠═88339ed4-68a8-11eb-025b-bda4f8caf107
# ╠═6575ce98-67f0-11eb-32d3-0bef0d249dd3
# ╟─f0268b78-6885-11eb-1ef6-439c25c3f010
# ╟─9a2b3718-68a9-11eb-0057-2dc8464b0dd4
# ╟─a4f73b92-68a9-11eb-228f-afbffd7bd49a
# ╟─867d27ee-67f0-11eb-0936-f316ccf824b6
# ╟─dc188ada-6800-11eb-3b5a-4907bc4bbffa
# ╠═50f269ae-6886-11eb-0975-47c5feb2bf43
# ╠═55351e56-6886-11eb-1c91-f9ea3d4e9b12
# ╠═8b62e64c-6886-11eb-0c13-79cafb18c87d
# ╠═95a073ac-6886-11eb-238d-3538f0899275
# ╠═9831175c-6886-11eb-2472-41d50880c5c0
# ╠═9ad11ef0-6886-11eb-37b3-8d36401d848e
# ╠═9fdb4e26-6886-11eb-141c-7d21e30c9e21
# ╠═a248a1ba-6886-11eb-2f81-6996389264b7
# ╠═a443c76a-6886-11eb-0160-7397360b3077
# ╠═a74e135c-6886-11eb-082d-2d8f9d8d2d6e
# ╟─da8824e4-688e-11eb-1418-75a5b015fb9f
# ╟─2878a90c-6895-11eb-3849-93faad3f4f7d
# ╟─2b9792f6-6895-11eb-3305-7f493a44f99f
# ╟─d1a03fb6-6886-11eb-3ae5-47203575b373
# ╟─0502376e-68c1-11eb-374c-af049fcdb28d
# ╟─093cde1a-68c1-11eb-0aff-cfceb9e7ffca
# ╟─b8bb38a0-67f1-11eb-089c-5f598630c7e9
# ╠═c2e62ca2-67f1-11eb-3d4b-cb41a8cf5f12
# ╠═decaa3c8-68cb-11eb-3460-e133e9c154e4
# ╟─c901233a-67f1-11eb-1af2-f110d820a560
# ╠═d03106c0-67f1-11eb-120b-1de57838ccc7
# ╟─d3d9d32e-67f1-11eb-0268-c7e98f09cad3
# ╟─da821ace-67f1-11eb-2c0b-63561ae3c7cc
# ╟─df2b0cb6-67f1-11eb-1d1d-e71fe439882d
# ╟─e718de30-67f1-11eb-0128-bb5a8b12028f
# ╟─eebc7f14-67f1-11eb-0035-ed3c54af7404
# ╟─f4a1b55e-67f1-11eb-2c90-23285b067b53
# ╟─f949e7f2-67f1-11eb-0825-9db20a8475b8
# ╟─02716f58-67f2-11eb-10b7-5fb40a406c40
