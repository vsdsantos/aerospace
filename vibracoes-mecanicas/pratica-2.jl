using Plots
plot()
ξ = 0.001
Tr(r) = 1 - sqrt((1+(2ξ*r)^2)/((1-r^2)^2+(2ξ*r)^2))
plot!(Tr, sqrt(2)*1.8, 20, label="ξ=0", l=:dash, c=:black)
ξ = .17
Tr(r) = 1 - sqrt((1+(2ξ*r)^2)/((1-r^2)^2+(2ξ*r)^2))
plot!(Tr, sqrt(2)*1.8, 20, label="ξ=0.17")

x = [59.67/3 28.67/3 40/3 50/3 10/2.2]
y = Tr.(x)
scatter!(x,y, label=["Motor CA 1" "Motor CA 2" "Bomba" "Gerador" "Prensa"])

plot!(xlabel="r", ylabel="I(r)")

savefig("vibes-p-2.png")
# pyplot()
