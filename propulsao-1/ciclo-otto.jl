
T0 = 273.15 + 15 # [K]
P0 = 101325 # [Pa] Controlado pela altitude
R_universal = 8314.34 # [J/kgmol/K]

VolDTotal = 8849e-6 # m3 vol total (cilindradas)
Ncil = 6 # N cilindros
VolD = VolDTotal/Ncil # volume de cada cilindro
rc = 8.7 # razão de compressão
λ_mistura = 0.9

air = Gas(287.04, 1.4) #J/kg/K
air_comb = Gas(289.0, 1.35)

E94 = Fuel(32e6, 9, λ_mistura)
AVGAS = Fuel(42e6, 14, λ_mistura)

ω_rpm = 1000:100:3000
N = ω_rpm./60 #rps
ω = 2 .*pi.*N # rad/s

using Plots; pyplot()

plot(color_palette=palette(:tab10, 4))
for carga in [1 .75 .65 .5]
	plot!(ω_rpm, ciclo_otto(E94, carga)[1],
		label=string("E94 - Carga ",Int64(carga*100), "%"))
end
for carga in [1 .75 .65 .5]
	plot!(ω_rpm, ciclo_otto(AVGAS, carga)[1],
		line=:dash,
		label=string("AVGAS - Carga ",Int64(carga*100), "%"))
end

plot!(xlabel="ω [rpm]", ylabel="Pot [kW]")
savefig("vel_pot.png")

plot(color_palette=palette(:tab10, 4))
for carga in [1 .75 .65 .5]
	plot!(ω_rpm, ciclo_otto(E94, carga)[2],
		label=string("E94 - Carga ",Int64(carga*100), "%"))
end
for carga in [1 .75 .65 .5]
	plot!(ω_rpm, ciclo_otto(AVGAS, carga)[2],
		line=:dash,
		label=string("AVGAS - Carga ",Int64(carga*100), "%"))
end

plot!(xlabel="ω [rpm]", ylabel="Consumo [kg/h]")

savefig("vel_consumo.png")

function ciclo_otto(fuel, η_vol)
	η_c, η_b, η_e, η_bo, ξ_bo, ξ_ex = 0.96, 0.66, 0.31, 0.28, 0.4, 0.95
	T1, P1, τ_ad, π_ad = processo_isobárico_não_ideal(T0, P0, η_vol)
	T2, P2, τ_c, π_c = compressão_isentrópica_não_ideal(T1, P1, air.γ, rc, η_c)
	T3, P3, τ_b, π_b = combustão_não_ideal(T2, P2, η_b, fuel, air, air_comb)
	T4, P4, τ_e, π_e = expansão_isentrópica_não_ideal(T3, P3, air.γ, rc, η_e)
	T5, P5, τ_bo, π_bo = blow_out(T4, P4, π_b, π_e, π_c, ξ_bo, η_bo)
	T6, P6, τ_ex, π_ex = processo_isobárico_não_ideal(T5, P5, ξ_ex)
	efm = 0.98
	WM = efm.*(air.cv.*τ_c.*τ_ad.*T0.*(τ_b.-1).-air_comb.cv.*τ_ad.*T0.*(τ_e.*τ_b.*τ_c-1)
				  .-(π_ex.*π_bo.*π_e.*π_b.*π_c.*π_ad.-1).*air.R.*T0)
	M = VolD.*π_ad.*P0./(air.R.*τ_ad.*T0)
	Torque = M.*WM.*Ncil./(4*pi)
	Pot = Torque.*ω
	mdot = 2*M.*N
	Cf = fuel.f*mdot
	Pot.*1e-3, Cf*3600
end

function não_ideal(T, P, τ, π)
	return τ.*T, π.*P, τ, π
end

function processo_isobárico_não_ideal(T, P, η)

	τ = 1
	π = η

	não_ideal(T, P, τ, π)
end

function compressão_isentrópica_não_ideal(T, P, γ, rc, η)
	τ = rc.^(γ.-1)
	π = τ.^(γ.*η./(γ.-1))

	não_ideal(T, P, τ, π)
end

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

function expansão_isentrópica_não_ideal(T, P, γ, rc, η)
	τ = 1 ./rc.^(γ.-1)
	π = τ.^(γ./η.*(γ.-1))

	não_ideal(T, P, τ, π)
end

function blow_out(T, P, π_b, π_e, π_c, ξ, η)
	π_bo = 1 ./(ξ.*π_e.*π_b.*π_c)
	τ_bo = π_bo./η

	não_ideal(T, P, τ_bo, π_bo)
end

struct Gas
	R
	PM
	γ
	cv
	Gas(R, γ) = new(R, R_universal/R, γ, R/(γ-1))
end

struct Fuel
	PCI::Real # J / kg
	AF_esteq::Real # kg air / kg fuel
	λ::Real
	AF::Real # kg air/ kg fuel
	f::Real # kg fuel / kg
	f_esteq::Real
	Fuel(PCI, AF_esteq, λ) = new(PCI, AF_esteq, λ, AF_esteq*λ, 1/(AF_esteq*λ+1), 1/(AF_esteq+1))
end
