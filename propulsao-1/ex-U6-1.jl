### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ c44932de-7c7c-11eb-06e3-951424edc1e3
md"# 1 - Turbofan - Ponto de Projeto"

# ╔═╡ acc7be0e-7e26-11eb-22e2-47ecc15e413c
md"""
Para executar este notebook _Pluto.jl_ em Julia, 
"""

# ╔═╡ d8973f7e-7c7c-11eb-39bd-27ad60cda98f
md"## Análise do Ciclo Não-Ideal"

# ╔═╡ f22985e6-7c7c-11eb-3cce-ddd32665d9fc
md"### Dados de Entrada"

# ╔═╡ 43a907c0-7c7d-11eb-3c0d-fdbfd5ac6939
begin
	# Dados do Voo 
	M_0 = 0.2 # Mach
	H_0 = 0 # Altitude [m]
	md"""
	**Dados de Voo**
	
	``M_0 = `` $M_0
	
	``H_0 = `` $H_0 m
	"""
end

# ╔═╡ d7905982-7c7d-11eb-24d1-f5cd11516664
begin
	h_PR = 4.2e7 # [J/kg]
	T_t4 = 1500 # [K]
	md"""
	**Dados de Combustível e limite tecnológico da turbina**
	
	``h_{PR} = `` $h_PR  J/Kg
	
	``T_{t4} = `` $T_t4 K
	"""
end

# ╔═╡ 9613a674-7c86-11eb-3161-d728807bbce0
begin
	γ_c, R_c, c_pc = 1.4, 287, 1004
	γ_t, R_t, c_pt = 1.3, 291, 1100
	md"""
	**Dados de Fluidos de Trabalho**
	
	Ar:
	
	``γ_c = `` $γ_c
	``\;R_c = `` $R_c
	``\;c_{pc} = `` $c_pc
	
	Gás Queimado: 
	
	``γ_t = `` $γ_t
	``\;R_t = `` $R_t
	``\;c_{pt} = `` $c_pt
	"""
end

# ╔═╡ 82b6201a-7c87-11eb-1a08-c503e5e9a831
md"### Entrada de Ar (0-1)"

# ╔═╡ 1ea2d978-7c88-11eb-0eb3-cfff38a8d2ef
md"### Entrada de Ar (1-2)"

# ╔═╡ ba023b52-7c88-11eb-05f0-89c9d783a843
π_d_max = 0.97

# ╔═╡ b8fecbbc-7c88-11eb-1de6-53aaece5a0a5
md"### Fan (2-2.1) e (2-13)"

# ╔═╡ 469ee0e2-7c8e-11eb-2aa6-6f7ed7dcb138
ϵ_f = 0.98

# ╔═╡ 9c11d642-7c8e-11eb-3978-5d49aa1d190e
π_f = 1.7

# ╔═╡ 043ced02-7c89-11eb-0392-0171011b0ec1
τ_f = π_f^((γ_c-1)/(γ_c*ϵ_f))

# ╔═╡ 2f2b0f76-7c89-11eb-06bc-e37e98000242
md"### Compressor de baixa (2.1-2.5)"

# ╔═╡ a1b7e54e-7c8e-11eb-0630-e12df2d06aa3
ϵ_cL = 0.95

# ╔═╡ d09d2a7e-7c8e-11eb-09a8-350be2a0d399
π_cL = 2.7

# ╔═╡ 3d9c13f2-7c89-11eb-3cf5-9d343f9cafa3
τ_cL = π_cL^((γ_c-1)/(γ_c*ϵ_cL))

# ╔═╡ 561cbab2-7c89-11eb-3c62-0b1eb21a832c
η_cL = (π_cL^((γ_c - 1)/γ_c) - 1)/(τ_cL - 1)

# ╔═╡ 7e5b7ed2-7c89-11eb-2bef-edc3ac8fc652
md"### Compressor de alta (2.5-3)"

# ╔═╡ ebde79fa-7c8e-11eb-2a47-b16e78fec3f0
ϵ_cH = 0.95

# ╔═╡ fa7c98ac-7c8e-11eb-1d16-0792d6b0df0b
π_cH = 11.6

# ╔═╡ 94464074-7c89-11eb-1ba0-7f00a43024dd
τ_cH = π_cH^((γ_c-1)/(γ_c*ϵ_cH))

# ╔═╡ 9f351136-7c89-11eb-2a05-c303485873a5
η_cH = (π_cL^((γ_c - 1)/γ_c) - 1)/(τ_cH - 1)

# ╔═╡ aa5f1584-7c89-11eb-277f-653faaad9991
md"### Combustor (3-4)"

# ╔═╡ 1cc9c08c-7c90-11eb-1f13-0773cfcb11a9
π_b = 0.98

# ╔═╡ 2b988c28-7c91-11eb-28d6-4927cbc3f473
η_b = 0.98

# ╔═╡ 313623ae-7c8a-11eb-0553-6b68a4b7a813
md"### Turbina de Alta (4-4.5)"

# ╔═╡ 3553d664-7c91-11eb-37f5-974597106a43
η_mH = 0.99

# ╔═╡ 53384d0e-7c91-11eb-07db-3d4a4fddfc96
ϵ_tH = 0.95

# ╔═╡ 66b60c88-7c8c-11eb-0ce0-196057938958
md"### Turbina de baixa (4.5-5)"

# ╔═╡ 017f87ec-7c8d-11eb-1d95-b343c324a6fa
α = 4.7

# ╔═╡ 65971598-7c91-11eb-1744-07431df54f78
η_mL = 0.99

# ╔═╡ 6baa5530-7c91-11eb-188c-2f0d05d9dd9e
ϵ_tL = 0.95

# ╔═╡ c27a25f2-7c91-11eb-1525-0fe0b84e3a05
md"### Tubeira central (5-9)"

# ╔═╡ f7570136-7c92-11eb-345e-0f86c88b44aa
π_n = 1

# ╔═╡ c46e44ea-7c98-11eb-040e-af0645db954c
τ_n = 1

# ╔═╡ 09badc2e-7c95-11eb-3672-c7526a63ddef
md"### Tubeira Fan (13-19)"

# ╔═╡ 16ab6690-7c97-11eb-04a3-b1d052193ff5
π_fn = 1

# ╔═╡ bc5b8f56-7c98-11eb-24bb-c3aaf58cc712
τ_fn = 1

# ╔═╡ 214914f8-7c9a-11eb-18f7-996de60df511
md"### Desempenho do motor"

# ╔═╡ 9b413ce0-7e22-11eb-25b6-ad9c49a8f08d
mdot_0 = 385

# ╔═╡ ea2cd72c-7e24-11eb-0477-8da0b298c35d
md"## Resultados"

# ╔═╡ f1ec599c-7e24-11eb-3358-2bf339878821
F_R = 14206

# ╔═╡ fe03c17a-7e24-11eb-3c27-05c9513f2652
S_R = 10.5

# ╔═╡ 357ad34a-7e26-11eb-3a8d-b30faf22ceb1
md"""
### Comentários
Verificamos que o empuxo foi subestimado e o consumo superestimado na análise do modelo não ideal. Isto pode seguir de uma temperatura máxima tecnologica maior do que a utlizada ou erros relativos a outros parâmetros
"""

# ╔═╡ 7692ba46-7c91-11eb-1d85-8dfb35abfffc
md"""
---

#### Funções auxiliares"""

# ╔═╡ c3ae95c8-7d06-11eb-2947-8f5b9de04880
function intake()
	τ = 1 + ((γ_c - 1)/2)*M_0^2
	π = τ^(γ_c/(γ_c-1))
	return τ, π
end

# ╔═╡ bfcc8fc0-7c87-11eb-0a60-41beaaee1b8d
begin
	τ_r, π_r = intake()
	md"""
	`` \tau_r = `` $τ_r
	
	`` \pi_r = `` $π_r
	"""
end

# ╔═╡ f491c584-7d06-11eb-0d37-2d60d1455216
function intake_recover(π_d_max)
	if M_0 > 1
		η = 1 - 0.075*(M_0 - 1)^1.35
	else
		η = 1
	end
	π = η*π_d_max
	τ =  π^((γ_c-1)/γ_c)
	return τ, π, η
end

# ╔═╡ 28fcc320-7c88-11eb-22e9-cb186bd660c5
begin
	τ_d, π_d, η_d = intake_recover(π_d_max)
	md"""
	`` \tau_d = `` $τ_d
	
	`` \pi_d = `` $π_d
	
	`` \eta_d = `` $η_d
	"""
end

# ╔═╡ 23da0d58-7d28-11eb-1b02-9f07003cadce
function nozzle_mach(P_t, P_ext, γ)
	sqrt((2/(γ-1))*((P_t/P_ext)^((γ-1)/γ) - 1))
end

# ╔═╡ bef37ab2-7d38-11eb-3823-53ff28521c73
function MFP(M, γ, R)
	(M*sqrt(γ/R))/(1+((γ-1)/2)*M^2)^((γ+1)/(2*(γ-1)))
end

# ╔═╡ ff91ff8c-7c8c-11eb-2afc-495616705eac
function us_atm(h)
	h = h
	γ = 1.4
	R = 286.2
	M = 29.05
	c_p = 1003.0
	P_ref = 101325 
	T_ref = 288.15
	
	if h <= 11000
		# for less of 11,000 meters
		T = T_ref- 0.00649 * h ;
		P = (P_ref * (T/T_ref)^5.256);
	elseif ( 11000 < h ) && ( h <= 25000 )
		# between 11000 and 25000 meters
		T = -56.46+273.15 ;
		P = 22650 * exp(1.73 - 0.000157 * h)
	else
		# above  25,000 meters
		T = (-131.21 + 0.00299 * h) + 273.16
		P = 2488 * (T/ 216.6)^(-11.388)
	end
	ρ = P/(R*T)
	a = sqrt(γ*T*R)
	return P, T, ρ, a
end

# ╔═╡ 28f5da64-7c8e-11eb-2a3a-9b653f40d55e
begin
	P_0, T_0, ρ_0, a_0 = us_atm(H_0)
	md"""
	``P_0 = `` $P_0 Pa
	
	``T_0 = `` $T_0 K
	
	``\rho_0 = `` $(round(ρ_0, digits=4)) kg/m³
	
	``a_0 = `` $(round(a_0, digits=1)) m/s
	"""
end

# ╔═╡ b4a56232-7c89-11eb-220b-17a37e543a21
τ_λ = c_pt*T_t4/(c_pc*T_0)

# ╔═╡ e4d1b73a-7c89-11eb-1b5f-71ac3c288183
f = (τ_λ - τ_r*τ_d*τ_f*τ_cL*τ_cH)/(η_b*h_PR/(c_pc*T_0) - τ_λ)

# ╔═╡ 3b449eac-7c8a-11eb-00db-130a3c3ff4c9
τ_tH = 1 - ((τ_cH - 1)/(η_mH*(1 + f)))*(τ_r*τ_d*τ_f*τ_cL/τ_λ)

# ╔═╡ 0d9828fa-7c8c-11eb-13a8-63db2380cc79
π_tH = τ_tH^(γ_t/((γ_t-1)*ϵ_tH))

# ╔═╡ 42e287ee-7c8c-11eb-3319-654e5e251016
η_tH = (τ_tH - 1)/(π_tH^((γ_t-1)/γ_t) - 1)

# ╔═╡ 9bbf20a2-7c8c-11eb-3b2d-fface5db91a3
τ_tL = 1 - ((α*(τ_f - 1) + (τ_f*τ_cL - 1))/(η_mL*(1 + f)))*(τ_r*τ_d/(τ_λ*τ_tH))

# ╔═╡ e2b0b822-7c8c-11eb-0cf0-496c1dadba19
π_tL = τ_tL^(γ_t/((γ_t-1)*ϵ_tL))

# ╔═╡ eaddd35e-7c8c-11eb-15a5-2376ec298ed9
η_tL = (τ_tL - 1)/(π_tL^((γ_t-1)/γ_t) - 1)

# ╔═╡ 203b3a6e-7c92-11eb-32bb-d5de837dca17
P_9 = P_0

# ╔═╡ cc54f994-7c91-11eb-1a52-398e8c538506
P_t9 = P_0*π_r*π_d*π_f*π_cL*π_cH*π_b*π_tH*π_tL*π_n

# ╔═╡ 42aa2b00-7c92-11eb-1c3f-8184c89a31ac
P_t9/P_9 < ((γ_t+1)/2)^(γ_t/(γ_t-1))

# ╔═╡ f27d4b92-7c93-11eb-363a-359709ef16b4
M_9 = nozzle_mach(P_t9, P_9, γ_t)

# ╔═╡ 50c21cb0-7c98-11eb-1624-114c4cc3ea9d
T_t9 = T_0*(c_pc/c_pt)*τ_λ*τ_tH*τ_tL*τ_n

# ╔═╡ db5a8718-7c98-11eb-25d7-4f2a5e4cc71a
T_9 = T_0*(T_t9/T_0)/(P_t9/P_9)^((γ_t-1)/γ_t)

# ╔═╡ 268f766c-7c99-11eb-2b3f-532f83455f94
V_9 = a_0*M_9*sqrt(γ_t*R_t*T_9/(γ_c*R_c*T_0))

# ╔═╡ c57c6ade-7c97-11eb-0862-ef03ca188946
F_c_esp = (a_0/(1+α))*((1+f)*(V_9/a_0) - M_0 + (1+f)*(R_t*T_9/T_0)/(R_c*V_9/a_0)*(1-P_0/P_9)/γ_c)

# ╔═╡ 18c32834-7c95-11eb-3350-153c47b1d2b3
P_19 = P_0

# ╔═╡ f46c1ae8-7c96-11eb-10e6-1d06ac42e632
P_t19 = P_0*π_r*π_d*π_f*π_fn

# ╔═╡ 2197738c-7c97-11eb-1d95-3fd50a54f033
P_t19/P_19 < ((γ_c+1)/2)^(γ_c/(γ_c-1))

# ╔═╡ 961432ce-7c97-11eb-0865-8d389d4bff83
M_19 = sqrt((2/(γ_c-1))*((P_t19/P_19)^((γ_c-1)/γ_c) - 1))

# ╔═╡ c3670dee-7c97-11eb-12d3-150e544a5841
T_t19 = T_0*τ_r*τ_f*τ_fn

# ╔═╡ a1a721b0-7c99-11eb-16d6-f75178410870
T_19 = T_0*(T_t19/T_0)/(P_t19/P_19)^((γ_c-1)/γ_c)

# ╔═╡ c7f2178a-7c99-11eb-2902-f137bd98436d
V_19 = a_0*M_19*sqrt(T_19/T_0)

# ╔═╡ db70ebe0-7c99-11eb-20f6-a3681cbecf40
F_f_esp = (α*a_0/(1+α))*(V_19/a_0 - M_0 + (T_19/T_0)/(V_19/a_0)*(1-P_0/P_19)/γ_c)

# ╔═╡ 2ddc1aa0-7c9a-11eb-3c76-69a94f583f06
begin
	F_esp = F_f_esp + F_c_esp
	md"Empuxo Específico: $(round(F_esp, digits=2)) N/kg/s"
end

# ╔═╡ 72b2befe-7c9a-11eb-2240-a9a3d41e4101
begin
	S = 1e6*f/((1+α)*F_esp)
	md"Consumo específico: $(round(S, digits=2)) g/(kN*s)"
end

# ╔═╡ 47a8fef0-7e25-11eb-137a-7fb0485d60b5
begin
	S_err = round(100*(S - S_R)/S_R, digits=1)
	md"Erro do Consumo específico: $S_err %"
end

# ╔═╡ a36024c2-7c9c-11eb-0586-e13afefa9139
begin
	F = mdot_0*F_esp/9.81
	md"Empuxo: $(round(F)) kgf"
end

# ╔═╡ 08527df6-7e25-11eb-38b7-4fce6f4ba61d
begin
	F_err = round(100*(F - F_R)/F_R, digits=1)
	md"Erro do Empuxo: $F_err %"
end

# ╔═╡ 54be0e12-7c9a-11eb-072e-737f011adb6d
begin
	FR = F_f_esp/F_c_esp
	md"Razão de Empuxo: $(round(FR, digits=3))"
end

# ╔═╡ 91ddd1a0-7c9b-11eb-2655-815aaf86ffe5
begin
	η_t = a_0^2*((1+f)*(V_9/a_0)^2 + α*(V_19/a_0)^2 - (1+α)*M_0^2)/(2f*h_PR)
	md"Eficiência térmica: $(round(η_t*100, digits=1))%"
end

# ╔═╡ c65c152c-7c9b-11eb-0ce0-2d90dab4e64e
begin
	η_p = 2M_0*((1+f)*(V_9/a_0) + α*(V_19/a_0)
		- (1+α)*M_0)/((1+f)*(V_9/a_0)^2 + α*(V_19/a_0)^2 - (1+α)*M_0^2)
	md"Eficiência propulsiva: $(round(η_p*100, digits=1))%"
end

# ╔═╡ 0884e9f6-7c9c-11eb-0eb3-3bcfa4ad9f8b
begin
	η_0 = η_p * η_t
	md"Eficiência Global: $(round(η_0*100, digits=1))%"
end

# ╔═╡ ca91d88c-7d38-11eb-3426-a74ea9d8a1f1
function mass_flow_compressor(π_d, π_f, π_cL, π_cH, π_b, f)
	MFP(1, γ_t, R_t)*π_r*π_d*π_f*π_cL*π_cH*π_b*P_0*A_41/(1+f)/sqrt(τ_λ*T_0)
end

# ╔═╡ Cell order:
# ╟─c44932de-7c7c-11eb-06e3-951424edc1e3
# ╠═acc7be0e-7e26-11eb-22e2-47ecc15e413c
# ╟─d8973f7e-7c7c-11eb-39bd-27ad60cda98f
# ╟─f22985e6-7c7c-11eb-3cce-ddd32665d9fc
# ╟─43a907c0-7c7d-11eb-3c0d-fdbfd5ac6939
# ╟─28f5da64-7c8e-11eb-2a3a-9b653f40d55e
# ╟─d7905982-7c7d-11eb-24d1-f5cd11516664
# ╟─9613a674-7c86-11eb-3161-d728807bbce0
# ╟─82b6201a-7c87-11eb-1a08-c503e5e9a831
# ╟─bfcc8fc0-7c87-11eb-0a60-41beaaee1b8d
# ╟─1ea2d978-7c88-11eb-0eb3-cfff38a8d2ef
# ╟─ba023b52-7c88-11eb-05f0-89c9d783a843
# ╟─28fcc320-7c88-11eb-22e9-cb186bd660c5
# ╟─b8fecbbc-7c88-11eb-1de6-53aaece5a0a5
# ╟─469ee0e2-7c8e-11eb-2aa6-6f7ed7dcb138
# ╟─9c11d642-7c8e-11eb-3978-5d49aa1d190e
# ╠═043ced02-7c89-11eb-0392-0171011b0ec1
# ╟─2f2b0f76-7c89-11eb-06bc-e37e98000242
# ╟─a1b7e54e-7c8e-11eb-0630-e12df2d06aa3
# ╟─d09d2a7e-7c8e-11eb-09a8-350be2a0d399
# ╠═3d9c13f2-7c89-11eb-3cf5-9d343f9cafa3
# ╠═561cbab2-7c89-11eb-3c62-0b1eb21a832c
# ╟─7e5b7ed2-7c89-11eb-2bef-edc3ac8fc652
# ╟─ebde79fa-7c8e-11eb-2a47-b16e78fec3f0
# ╟─fa7c98ac-7c8e-11eb-1d16-0792d6b0df0b
# ╠═94464074-7c89-11eb-1ba0-7f00a43024dd
# ╠═9f351136-7c89-11eb-2a05-c303485873a5
# ╟─aa5f1584-7c89-11eb-277f-653faaad9991
# ╠═b4a56232-7c89-11eb-220b-17a37e543a21
# ╟─1cc9c08c-7c90-11eb-1f13-0773cfcb11a9
# ╟─2b988c28-7c91-11eb-28d6-4927cbc3f473
# ╠═e4d1b73a-7c89-11eb-1b5f-71ac3c288183
# ╟─313623ae-7c8a-11eb-0553-6b68a4b7a813
# ╟─3553d664-7c91-11eb-37f5-974597106a43
# ╟─53384d0e-7c91-11eb-07db-3d4a4fddfc96
# ╠═3b449eac-7c8a-11eb-00db-130a3c3ff4c9
# ╠═0d9828fa-7c8c-11eb-13a8-63db2380cc79
# ╠═42e287ee-7c8c-11eb-3319-654e5e251016
# ╟─66b60c88-7c8c-11eb-0ce0-196057938958
# ╟─017f87ec-7c8d-11eb-1d95-b343c324a6fa
# ╟─65971598-7c91-11eb-1744-07431df54f78
# ╟─6baa5530-7c91-11eb-188c-2f0d05d9dd9e
# ╠═9bbf20a2-7c8c-11eb-3b2d-fface5db91a3
# ╠═e2b0b822-7c8c-11eb-0cf0-496c1dadba19
# ╠═eaddd35e-7c8c-11eb-15a5-2376ec298ed9
# ╟─c27a25f2-7c91-11eb-1525-0fe0b84e3a05
# ╠═203b3a6e-7c92-11eb-32bb-d5de837dca17
# ╟─f7570136-7c92-11eb-345e-0f86c88b44aa
# ╟─c46e44ea-7c98-11eb-040e-af0645db954c
# ╠═cc54f994-7c91-11eb-1a52-398e8c538506
# ╠═42aa2b00-7c92-11eb-1c3f-8184c89a31ac
# ╠═f27d4b92-7c93-11eb-363a-359709ef16b4
# ╠═50c21cb0-7c98-11eb-1624-114c4cc3ea9d
# ╠═db5a8718-7c98-11eb-25d7-4f2a5e4cc71a
# ╠═268f766c-7c99-11eb-2b3f-532f83455f94
# ╠═c57c6ade-7c97-11eb-0862-ef03ca188946
# ╟─09badc2e-7c95-11eb-3672-c7526a63ddef
# ╠═18c32834-7c95-11eb-3350-153c47b1d2b3
# ╟─16ab6690-7c97-11eb-04a3-b1d052193ff5
# ╟─bc5b8f56-7c98-11eb-24bb-c3aaf58cc712
# ╠═f46c1ae8-7c96-11eb-10e6-1d06ac42e632
# ╠═2197738c-7c97-11eb-1d95-3fd50a54f033
# ╠═961432ce-7c97-11eb-0865-8d389d4bff83
# ╠═c3670dee-7c97-11eb-12d3-150e544a5841
# ╠═a1a721b0-7c99-11eb-16d6-f75178410870
# ╠═c7f2178a-7c99-11eb-2902-f137bd98436d
# ╠═db70ebe0-7c99-11eb-20f6-a3681cbecf40
# ╟─214914f8-7c9a-11eb-18f7-996de60df511
# ╟─2ddc1aa0-7c9a-11eb-3c76-69a94f583f06
# ╟─54be0e12-7c9a-11eb-072e-737f011adb6d
# ╟─72b2befe-7c9a-11eb-2240-a9a3d41e4101
# ╟─91ddd1a0-7c9b-11eb-2655-815aaf86ffe5
# ╟─c65c152c-7c9b-11eb-0ce0-2d90dab4e64e
# ╟─0884e9f6-7c9c-11eb-0eb3-3bcfa4ad9f8b
# ╟─9b413ce0-7e22-11eb-25b6-ad9c49a8f08d
# ╟─a36024c2-7c9c-11eb-0586-e13afefa9139
# ╟─ea2cd72c-7e24-11eb-0477-8da0b298c35d
# ╟─f1ec599c-7e24-11eb-3358-2bf339878821
# ╟─fe03c17a-7e24-11eb-3c27-05c9513f2652
# ╟─08527df6-7e25-11eb-38b7-4fce6f4ba61d
# ╟─47a8fef0-7e25-11eb-137a-7fb0485d60b5
# ╠═357ad34a-7e26-11eb-3a8d-b30faf22ceb1
# ╟─7692ba46-7c91-11eb-1d85-8dfb35abfffc
# ╠═c3ae95c8-7d06-11eb-2947-8f5b9de04880
# ╠═f491c584-7d06-11eb-0d37-2d60d1455216
# ╠═23da0d58-7d28-11eb-1b02-9f07003cadce
# ╠═ca91d88c-7d38-11eb-3426-a74ea9d8a1f1
# ╠═bef37ab2-7d38-11eb-3823-53ff28521c73
# ╠═ff91ff8c-7c8c-11eb-2afc-495616705eac
