### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# ╔═╡ b4a18d80-6166-11eb-192b-7d5a7128f26c
using DataDeps, GoogleDrive, DataFrames, CSV

# ╔═╡ accaa90e-616e-11eb-0c99-0778cf32b5d9
using Plots; plotlyjs()

# ╔═╡ 0d2943c2-6161-11eb-2866-93e1f7e9c1d7
md"# Projeto Conceitual"

# ╔═╡ 34837e56-6161-11eb-0fd6-7d139cad351a
md"""
## Requisitos Iniciais
 - Tripulantes: 2
 - Passageiros: 9
 - Carga Paga Máxima: 2500 lb
 - Velocidade de Cruzeiro: 240 KIAS
 - Alcance: 540 nmi + 45 min reserva IFR
 - Teto de Serviço: 12500 ft
"""

# ╔═╡ 3beaaa44-6162-11eb-141d-e31770669150
md"""
## Métodos comparativos
"""

# ╔═╡ 9f8492ee-6170-11eb-1f3c-c9a6b6ca79bd
begin
	datadep_tag = "ProjetoConceitual v5"
	datadep_url = "https://docs.google.com/spreadsheets/d/1wskTJU3e-_4RpCuRS6iiX7ig8OGU663fo2VEw_tMX_Y/edit?usp=sharing"
	datadep_file = "TabelaComparativa-Dados.csv"
	datadep_description = """
	Tabela Comparativa de Aeronaves
	Projetos 1 - UFMG 2021
	"""
end

# ╔═╡ d53cf276-616b-11eb-1fb6-63cb5719099f
begin
	register(DataDep(datadep_tag, datadep_description, sheet_handler(datadep_url)))
	datadep = string()
	raw_df = DataFrame(CSV.File(@datadep_str "$datadep_tag/$datadep_file"))
	md"Downloading data..."
end

# ╔═╡ b7a7d7ac-616e-11eb-35e2-e9df341beea4
md"Processing data..."

# ╔═╡ df1a536c-6170-11eb-2fd6-d9e99cf8605b
begin
	df = raw_df[2:end,:]
	df[!,:PAX] = parse.(Int64, df[:,:PAX])
	df[!,:PotMax] = parse.(Float64, df[:,:PotMax])
	df[!,:MTOW] = parse.(Float64, df[:,:MTOW])
	df[!,:AR] = parse.(Float64, df[:,:AR])
	df[!,:VelCruz] = parse.(Float64, df[:,:VelCruz])
	df[!,:Alcance] = parse.(Float64, df[:,:Alcance])
	df
end

# ╔═╡ b52dedd6-616e-11eb-16d4-71640fa635da
md"### Potência Máxima vs. MTOW"

# ╔═╡ 5de72bfc-616c-11eb-2b78-f5fae1390150
begin
	labels = unique(df, :Tipo).Tipo
	aircrafts = []
	for l in labels
		push!(aircrafts, (df[df.Tipo .== l,:], l))
	end
	md"Categorization..."
end

# ╔═╡ 57efc74a-616c-11eb-1ff8-e1d8f99850b2
begin
	plot()
	for (dfi, label) in aircrafts
		x = dfi.MTOW
		y = dfi.PotMax
		scatter!(x,y,label=label,
			series_annotations=text.(dfi.Nome, 8, :top))
	end
	plot!(xlabel="MTOW [kg]", ylabel="Pot Max [kW]", legend=:topleft)
end

# ╔═╡ 8d236c82-6711-11eb-37af-93bf55ca403f
bigbreak = html"<br><br><br><br><br>";

# ╔═╡ 14ee22a0-6711-11eb-29c7-95e4ed89078f
bigbreak

# ╔═╡ Cell order:
# ╟─0d2943c2-6161-11eb-2866-93e1f7e9c1d7
# ╟─34837e56-6161-11eb-0fd6-7d139cad351a
# ╟─3beaaa44-6162-11eb-141d-e31770669150
# ╠═b4a18d80-6166-11eb-192b-7d5a7128f26c
# ╠═9f8492ee-6170-11eb-1f3c-c9a6b6ca79bd
# ╠═d53cf276-616b-11eb-1fb6-63cb5719099f
# ╠═b7a7d7ac-616e-11eb-35e2-e9df341beea4
# ╟─df1a536c-6170-11eb-2fd6-d9e99cf8605b
# ╟─b52dedd6-616e-11eb-16d4-71640fa635da
# ╠═accaa90e-616e-11eb-0c99-0778cf32b5d9
# ╠═5de72bfc-616c-11eb-2b78-f5fae1390150
# ╟─57efc74a-616c-11eb-1ff8-e1d8f99850b2
# ╟─14ee22a0-6711-11eb-29c7-95e4ed89078f
# ╟─8d236c82-6711-11eb-37af-93bf55ca403f
