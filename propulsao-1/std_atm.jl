### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ 67aca676-63e7-11eb-39b7-1740ee96094a
using Plots; pyplot()

# ╔═╡ 997bb8f6-63e7-11eb-009f-354ecc5f7902
function us_atm(h)
	h = h*1000
	gamma = 1.4
	R = 286.2
	M = 29.05
	cp = 1003.0
	Pref = 101325 
	Tref = 288.15
	if(h <= 11000)
		# for less of 11,000 meters
		T = Tref- 0.00649 * h ;
		P = (Pref * (T/Tref)^5.256);
	elseif(( 11000 < h ) && ( h <= 25000 ))
		# between 11000 and 25000 meters
		T = -56.46+273.15 ;
		P = 22650 * exp(1.73 - 0.000157 * h) ;    
	else
		# above  25,000 meters
		T = (-131.21 + 0.00299 * h) + 273.16;
		P = 2488 * (T/ 216.6)^(-11.388);
	end
	rho = (P/(R*T));
	a = sqrt( gamma*T*R);
	return P
end

# ╔═╡ 00cbf280-63e8-11eb-29c3-fd73781be65b
begin
	plot()
	x = 0:1:100
	y = us_atm.(x)
	plot(x,y,label="US Standard Atmosphere", xlabel="Altitude [km]",ylabel="Pressão [Pa]", minorgrid=true, minorticks=true, yscale=:log10)
end

# ╔═╡ Cell order:
# ╠═67aca676-63e7-11eb-39b7-1740ee96094a
# ╠═997bb8f6-63e7-11eb-009f-354ecc5f7902
# ╠═00cbf280-63e8-11eb-29c3-fd73781be65b
