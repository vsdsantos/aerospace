using DataDeps, GoogleDrive, Plots, CSV, DataFrames; plotlyjs()

data_url="https://drive.google.com/drive/folders/1Y6FggqZNFlPdfN7GatmiJIotl6-va8sI?usp=sharing"
data_tag = "Ensaio Tracao v1"
register(DataDep(data_tag,"Laboratorio de Estruturas", data_url))

files = [:al1 "CP1_aluminio.txt"
         :al2 "CP2_aluminio.txt"
         :cf1 "CP3_carbono.txt"
         :cf2 "CP4_carbono.txt"
         :cf3 "CP5_carbono.txt"
         :gf1 "CP6_vidro.txt"
         :gf2 "CP7_vidro.txt"
         :gf3 "CP8_vidro.txt"]


dfs = Dict()
for i in 1:size(files,1)
    df = DataFrame(
        CSV.File(string(data_tag,"/",files[i,2]),
                datarow=22,
                header=20:21,
                normalizenames=true))
    dfs[files[i,1]] = df
end


begin # plot individual
    L = 123
    A = 24
    df = dfs[:gf3]
    σ = df.Force_N./A
    ε = df.Stroke_mm./L
    plot(ε, σ, label="Ensaio")
end

begin
    min_ϵ, max_ϵ = 0.001, 0.039
    df_lin = df[(ε .> min_ϵ) .* (ε .< max_ϵ), :]
    σ_lin = df_lin.Force_N./A
    ε_lin = df_lin.Stroke_mm./L
    M  = hcat(ones(size(ε_lin)),ε_lin)
    a, b = M\σ_lin
    plot(ε_lin, σ_lin)
end

begin
    E(x) = b.*x
    E02(x) = b.*(x.-0.002)
    E85(x) = (0.85*b).*x
    E70(x) = (0.7*b).*x
    ε_n = ε .+ a/b
    plot(ε_n, σ, label="Ensaio")
    plot!(E, 0, max_ϵ*1.5, label=string("E=",round(b)," MPa"))
    plot!(E02, 0, max_ϵ*1.5, label=string("σ02="," MPa"))
    plot!(E85, 0, max_ϵ*1.5, label="E85", line=:dash)
    plot!(E70, 0, max_ϵ*1.5, label="E70", line=:dash)
end

begin
    amostras = [:gf1 :gf2 :gf3]
    L = 123
    A = 24
    p = plot()
    for (i,k) in enumerate(amostras)
        df = dfs[k]
        σ = df.Force_N./A
        ε = df.Stroke_mm./L
        plot!(ε, σ, label=string("Ensaio ",i+5), line=:dash, alpha=0.5)
    end
    plot!(xlabel="ε", ylabel="f [MPa]")
    savefig("analise_gf.png")
    p
end

d = vcat(σ1, σ2, σ3)
egf = vcat(ε1, ε2, ε3)
M = hcat(ones(size(egf)),egf)
a, b = M\d
plot!(ε1, σ1, label="", alpha=0.7)
plot!(ε2, σ2, label="", alpha=0.7)
plot!(ε3, σ3, label="", alpha=0.7)
E(x) = a .+ b.*x
plot!(E,0, 0.04, label="Regresão", w=2)

lott = DataFrame(CSV.File("/home/victor/Downloads/ET_ensaio1.txt"))
plot()
plot!(lott[2:end-1,1],lott[2:end-1,2],label="Ensaios")
plot!(lott[2:end-1,1],lott[2:end-1,3],label="Ramberg-Osgood")
plot!(xlabel="f [MPa]", ylabel="Et [Mpa]")
savefig("lott1.png")

lott = DataFrame(CSV.File("/home/victor/Downloads/ET_ensaio2.txt"))
plot()
plot!(lott[2:end-1,1],lott[2:end-1,2],label="Ensaios")
plot!(lott[2:end-1,1],lott[2:end-1,3],label="Ramberg-Osgood")
plot!(xlabel="f [MPa]", ylabel="Et [Mpa]")
savefig("lott2.png")
